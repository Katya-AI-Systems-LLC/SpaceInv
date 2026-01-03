# Russian Cloud Monitoring and Alerting Scripts

## Multi-Cloud Monitoring Dashboard

### Monitoring Dashboard Configuration
```python
# russian_cloud_monitoring.py
import json
import time
import asyncio
import aiohttp
from datetime import datetime, timedelta
from typing import Dict, List, Optional
from dataclasses import dataclass, asdict

@dataclass
class CloudMetrics:
    provider: str
    url: str
    response_time: float
    status_code: int
    is_healthy: bool
    timestamp: datetime
    error_message: Optional[str] = None

@dataclass
class SystemMetrics:
    cpu_usage: float
    memory_usage: float
    disk_usage: float
    network_in: float
    network_out: float
    timestamp: datetime

class RussianCloudMonitor:
    def __init__(self, config_file: str):
        self.config = self.load_config(config_file)
        self.providers = self.config.get('providers', {})
        self.metrics_history: Dict[str, List[CloudMetrics]] = {}
        self.alert_thresholds = self.config.get('monitoring', {}).get('alert_thresholds', {})
        
    def load_config(self, config_file: str) -> Dict:
        """Load configuration from file"""
        with open(config_file, 'r') as f:
            return json.load(f)
    
    async def check_provider_health(self, session: aiohttp.ClientSession, provider: str) -> CloudMetrics:
        """Check health of a specific cloud provider"""
        provider_config = self.providers.get(provider, {})
        url = provider_config.get('health_check_url')
        
        if not url:
            return CloudMetrics(
                provider=provider,
                url="",
                response_time=0,
                status_code=0,
                is_healthy=False,
                timestamp=datetime.utcnow(),
                error_message="No health check URL configured"
            )
        
        start_time = time.time()
        try:
            async with session.get(url, timeout=aiohttp.ClientTimeout(total=30)) as response:
                response_time = (time.time() - start_time) * 1000  # Convert to ms
                
                return CloudMetrics(
                    provider=provider,
                    url=url,
                    response_time=response_time,
                    status_code=response.status,
                    is_healthy=response.status == 200,
                    timestamp=datetime.utcnow()
                )
        except Exception as e:
            response_time = (time.time() - start_time) * 1000
            return CloudMetrics(
                provider=provider,
                url=url,
                response_time=response_time,
                status_code=0,
                is_healthy=False,
                timestamp=datetime.utcnow(),
                error_message=str(e)
            )
    
    async def monitor_all_providers(self) -> Dict[str, CloudMetrics]:
        """Monitor all cloud providers"""
        async with aiohttp.ClientSession() as session:
            tasks = [self.check_provider_health(session, provider) for provider in self.providers.keys()]
            results = await asyncio.gather(*tasks)
            return {result.provider: result for result in results}
    
    def store_metrics(self, metrics: Dict[str, CloudMetrics]):
        """Store metrics in history"""
        for provider, metric in metrics.items():
            if provider not in self.metrics_history:
                self.metrics_history[provider] = []
            
            self.metrics_history[provider].append(metric)
            
            # Keep only last 1000 metrics per provider
            if len(self.metrics_history[provider]) > 1000:
                self.metrics_history[provider] = self.metrics_history[provider][-1000:]
    
    def check_alert_conditions(self, metrics: Dict[str, CloudMetrics]) -> List[Dict]:
        """Check alert conditions and return alerts"""
        alerts = []
        
        for provider, metric in metrics.items():
            # Health check failure
            if not metric.is_healthy:
                alerts.append({
                    "type": "health_check_failure",
                    "provider": provider,
                    "severity": "critical",
                    "message": f"Health check failed for {provider}",
                    "timestamp": metric.timestamp.isoformat(),
                    "details": {
                        "error": metric.error_message,
                        "url": metric.url
                    }
                })
            
            # Response time threshold
            response_time_threshold = self.alert_thresholds.get('response_time', 2000)
            if metric.response_time > response_time_threshold:
                alerts.append({
                    "type": "response_time_high",
                    "provider": provider,
                    "severity": "warning",
                    "message": f"Response time too high for {provider}: {metric.response_time:.2f}ms",
                    "timestamp": metric.timestamp.isoformat(),
                    "details": {
                        "response_time": metric.response_time,
                        "threshold": response_time_threshold
                    }
                })
        
        return alerts
    
    def send_alert(self, alert: Dict):
        """Send alert to configured channels"""
        webhook_url = self.config.get('monitoring', {}).get('webhook_url')
        
        if not webhook_url:
            return
        
        # Format alert message
        color = {
            "critical": "danger",
            "warning": "warning",
            "info": "good"
        }.get(alert['severity'], "warning")
        
        message = {
            "text": f"🚨 Russian Cloud Alert: {alert['type'].replace('_', ' ').title()}",
            "attachments": [{
                "color": color,
                "fields": [{
                    "title": "Provider",
                    "value": alert['provider'],
                    "short": True
                }, {
                    "title": "Severity",
                    "value": alert['severity'].title(),
                    "short": True
                }, {
                    "title": "Message",
                    "value": alert['message'],
                    "short": False
                }, {
                    "title": "Time",
                    "value": alert['timestamp'],
                    "short": True
                }]
            }]
        }
        
        # Send to webhook
        try:
            import requests
            requests.post(webhook_url, json=message, timeout=10)
        except Exception as e:
            print(f"Failed to send alert: {e}")
    
    async def run_monitoring_cycle(self):
        """Run a complete monitoring cycle"""
        print(f"🔍 Starting monitoring cycle at {datetime.utcnow()}")
        
        # Monitor all providers
        metrics = await self.monitor_all_providers()
        
        # Store metrics
        self.store_metrics(metrics)
        
        # Check for alerts
        alerts = self.check_alert_conditions(metrics)
        
        # Send alerts
        for alert in alerts:
            self.send_alert(alert)
        
        # Print summary
        healthy_count = sum(1 for m in metrics.values() if m.is_healthy)
        total_count = len(metrics)
        
        print(f"📊 Monitoring cycle completed: {healthy_count}/{total_count} providers healthy")
        
        if alerts:
            print(f"🚨 {len(alerts)} alerts generated")
        
        return metrics, alerts
    
    def generate_dashboard_data(self) -> Dict:
        """Generate dashboard data"""
        dashboard = {
            "timestamp": datetime.utcnow().isoformat(),
            "providers": {},
            "summary": {
                "total_providers": len(self.providers),
                "healthy_providers": 0,
                "unhealthy_providers": 0,
                "average_response_time": 0
            }
        }
        
        all_response_times = []
        
        for provider, history in self.metrics_history.items():
            if not history:
                continue
            
            latest = history[-1]
            
            # Calculate provider stats
            response_times = [m.response_time for m in history if m.is_healthy]
            avg_response_time = sum(response_times) / len(response_times) if response_times else 0
            
            dashboard["providers"][provider] = {
                "current_status": "healthy" if latest.is_healthy else "unhealthy",
                "latest_response_time": latest.response_time,
                "average_response_time": avg_response_time,
                "uptime_percentage": sum(1 for m in history if m.is_healthy) / len(history) * 100,
                "last_check": latest.timestamp.isoformat(),
                "error_message": latest.error_message
            }
            
            if latest.is_healthy:
                dashboard["summary"]["healthy_providers"] += 1
                all_response_times.append(latest.response_time)
            else:
                dashboard["summary"]["unhealthy_providers"] += 1
        
        # Calculate overall average response time
        if all_response_times:
            dashboard["summary"]["average_response_time"] = sum(all_response_times) / len(all_response_times)
        
        return dashboard
    
    async def start_continuous_monitoring(self, interval: int = 60):
        """Start continuous monitoring"""
        print(f"🚀 Starting continuous monitoring with {interval}s interval")
        
        while True:
            try:
                await self.run_monitoring_cycle()
                await asyncio.sleep(interval)
            except KeyboardInterrupt:
                print("🛑 Monitoring stopped by user")
                break
            except Exception as e:
                print(f"❌ Monitoring error: {e}")
                await asyncio.sleep(interval)

# Usage example
async def main():
    monitor = RussianCloudMonitor('russian-clouds-config.json')
    
    # Run single monitoring cycle
    metrics, alerts = await monitor.run_monitoring_cycle()
    
    # Generate dashboard data
    dashboard = monitor.generate_dashboard_data()
    print(json.dumps(dashboard, indent=2))
    
    # Start continuous monitoring
    # await monitor.start_continuous_monitoring()

if __name__ == "__main__":
    asyncio.run(main())
```

### Performance Monitoring Script
```python
# performance_monitor.py
import psutil
import asyncio
import aiohttp
from datetime import datetime
from typing import Dict, List

class PerformanceMonitor:
    def __init__(self):
        self.metrics_history = []
        
    def get_system_metrics(self) -> Dict:
        """Get current system metrics"""
        return {
            "cpu_percent": psutil.cpu_percent(interval=1),
            "memory_percent": psutil.virtual_memory().percent,
            "disk_percent": psutil.disk_usage('/').percent,
            "network_io": psutil.net_io_counters()._asdict(),
            "timestamp": datetime.utcnow().isoformat()
        }
    
    async def measure_cloud_performance(self, session: aiohttp.ClientSession, url: str) -> Dict:
        """Measure performance of a cloud endpoint"""
        start_time = datetime.utcnow()
        
        try:
            async with session.get(url, timeout=aiohttp.ClientTimeout(total=30)) as response:
                end_time = datetime.utcnow()
                response_time = (end_time - start_time).total_seconds() * 1000
                
                return {
                    "url": url,
                    "response_time_ms": response_time,
                    "status_code": response.status,
                    "content_length": len(await response.read()),
                    "timestamp": start_time.isoformat(),
                    "success": True
                }
        except Exception as e:
            end_time = datetime.utcnow()
            response_time = (end_time - start_time).total_seconds() * 1000
            
            return {
                "url": url,
                "response_time_ms": response_time,
                "status_code": 0,
                "content_length": 0,
                "timestamp": start_time.isoformat(),
                "success": False,
                "error": str(e)
            }
    
    async def run_performance_test(self, urls: List[str]) -> Dict:
        """Run performance test on multiple URLs"""
        async with aiohttp.ClientSession() as session:
            tasks = [self.measure_cloud_performance(session, url) for url in urls]
            results = await asyncio.gather(*tasks)
            
            system_metrics = self.get_system_metrics()
            
            return {
                "system_metrics": system_metrics,
                "cloud_metrics": results,
                "summary": {
                    "total_tests": len(results),
                    "successful_tests": sum(1 for r in results if r["success"]),
                    "average_response_time": sum(r["response_time_ms"] for r in results if r["success"]) / max(1, sum(1 for r in results if r["success"])),
                    "timestamp": datetime.utcnow().isoformat()
                }
            }

# Usage example
async def main():
    monitor = PerformanceMonitor()
    
    urls = [
        "https://space-invaders.yandexcloud.net",
        "https://space-invaders.vkcloud.com",
        "https://space-invaders.selectel.ru"
    ]
    
    results = await monitor.run_performance_test(urls)
    print(json.dumps(results, indent=2))

if __name__ == "__main__":
    asyncio.run(main())
```

### Alert Management System
```python
# alert_manager.py
import json
import asyncio
from datetime import datetime, timedelta
from typing import Dict, List, Optional
from dataclasses import dataclass, asdict
from enum import Enum

class AlertSeverity(Enum):
    INFO = "info"
    WARNING = "warning"
    CRITICAL = "critical"

@dataclass
class Alert:
    id: str
    type: str
    provider: str
    severity: AlertSeverity
    message: str
    timestamp: datetime
    resolved: bool = False
    resolved_at: Optional[datetime] = None
    details: Optional[Dict] = None

class AlertManager:
    def __init__(self, config_file: str):
        self.config = self.load_config(config_file)
        self.alerts: Dict[str, Alert] = {}
        self.alert_rules = self.config.get('alert_rules', [])
        self.notification_channels = self.config.get('notification_channels', [])
        
    def load_config(self, config_file: str) -> Dict:
        """Load configuration from file"""
        with open(config_file, 'r') as f:
            return json.load(f)
    
    def create_alert(self, alert_type: str, provider: str, severity: AlertSeverity, message: str, details: Optional[Dict] = None) -> Alert:
        """Create a new alert"""
        alert_id = f"{provider}_{alert_type}_{int(datetime.utcnow().timestamp())}"
        
        alert = Alert(
            id=alert_id,
            type=alert_type,
            provider=provider,
            severity=severity,
            message=message,
            timestamp=datetime.utcnow(),
            details=details
        )
        
        self.alerts[alert_id] = alert
        return alert
    
    def resolve_alert(self, alert_id: str):
        """Resolve an alert"""
        if alert_id in self.alerts:
            self.alerts[alert_id].resolved = True
            self.alerts[alert_id].resolved_at = datetime.utcnow()
    
    def get_active_alerts(self) -> List[Alert]:
        """Get all active (unresolved) alerts"""
        return [alert for alert in self.alerts.values() if not alert.resolved]
    
    def get_alerts_by_provider(self, provider: str) -> List[Alert]:
        """Get all alerts for a specific provider"""
        return [alert for alert in self.alerts.values() if alert.provider == provider]
    
    def get_alerts_by_severity(self, severity: AlertSeverity) -> List[Alert]:
        """Get all alerts by severity"""
        return [alert for alert in self.alerts.values() if alert.severity == severity]
    
    async def send_notification(self, alert: Alert):
        """Send notification for alert"""
        for channel in self.notification_channels:
            if channel['type'] == 'slack':
                await self.send_slack_notification(channel, alert)
            elif channel['type'] == 'email':
                await self.send_email_notification(channel, alert)
            elif channel['type'] == 'webhook':
                await self.send_webhook_notification(channel, alert)
    
    async def send_slack_notification(self, channel: Dict, alert: Alert):
        """Send Slack notification"""
        webhook_url = channel['webhook_url']
        
        color = {
            AlertSeverity.INFO: "good",
            AlertSeverity.WARNING: "warning",
            AlertSeverity.CRITICAL: "danger"
        }.get(alert.severity, "warning")
        
        message = {
            "text": f"🚨 Alert: {alert.type.replace('_', ' ').title()}",
            "attachments": [{
                "color": color,
                "fields": [{
                    "title": "Provider",
                    "value": alert.provider,
                    "short": True
                }, {
                    "title": "Severity",
                    "value": alert.severity.value.title(),
                    "short": True
                }, {
                    "title": "Message",
                    "value": alert.message,
                    "short": False
                }, {
                    "title": "Time",
                    "value": alert.timestamp.isoformat(),
                    "short": True
                }]
            }]
        }
        
        try:
            import aiohttp
            async with aiohttp.ClientSession() as session:
                await session.post(webhook_url, json=message)
        except Exception as e:
            print(f"Failed to send Slack notification: {e}")
    
    async def send_email_notification(self, channel: Dict, alert: Alert):
        """Send email notification"""
        # Implementation would depend on email service
        print(f"Email notification for {alert.id}: {alert.message}")
    
    async def send_webhook_notification(self, channel: Dict, alert: Alert):
        """Send webhook notification"""
        webhook_url = channel['webhook_url']
        
        payload = {
            "alert_id": alert.id,
            "type": alert.type,
            "provider": alert.provider,
            "severity": alert.severity.value,
            "message": alert.message,
            "timestamp": alert.timestamp.isoformat(),
            "details": alert.details
        }
        
        try:
            import aiohttp
            async with aiohttp.ClientSession() as session:
                await session.post(webhook_url, json=payload)
        except Exception as e:
            print(f"Failed to send webhook notification: {e}")
    
    def check_alert_rules(self, metrics: Dict):
        """Check alert rules against metrics"""
        for rule in self.alert_rules:
            self.evaluate_rule(rule, metrics)
    
    def evaluate_rule(self, rule: Dict, metrics: Dict):
        """Evaluate a single alert rule"""
        provider = rule['provider']
        condition = rule['condition']
        threshold = rule['threshold']
        severity = AlertSeverity(rule['severity'])
        message = rule['message']
        
        provider_metrics = metrics.get(provider)
        if not provider_metrics:
            return
        
        # Evaluate condition
        triggered = False
        
        if condition == 'health_check_failed':
            triggered = not provider_metrics.get('is_healthy', True)
        elif condition == 'response_time_high':
            response_time = provider_metrics.get('response_time', 0)
            triggered = response_time > threshold
        elif condition == 'status_code_error':
            status_code = provider_metrics.get('status_code', 200)
            triggered = status_code >= 400
        
        if triggered:
            # Check if alert already exists
            existing_alerts = self.get_alerts_by_provider(provider)
            existing_alert = next((a for a in existing_alerts if a.type == condition and not a.resolved), None)
            
            if not existing_alert:
                alert = self.create_alert(condition, provider, severity, message, provider_metrics)
                asyncio.create_task(self.send_notification(alert))
        else:
            # Resolve existing alerts for this condition
            existing_alerts = self.get_alerts_by_provider(provider)
            for alert in existing_alerts:
                if alert.type == condition and not alert.resolved:
                    self.resolve_alert(alert.id)
    
    def get_alert_summary(self) -> Dict:
        """Get alert summary"""
        active_alerts = self.get_active_alerts()
        
        return {
            "total_alerts": len(self.alerts),
            "active_alerts": len(active_alerts),
            "resolved_alerts": len(self.alerts) - len(active_alerts),
            "critical_alerts": len(self.get_alerts_by_severity(AlertSeverity.CRITICAL)),
            "warning_alerts": len(self.get_alerts_by_severity(AlertSeverity.WARNING)),
            "info_alerts": len(self.get_alerts_by_severity(AlertSeverity.INFO)),
            "timestamp": datetime.utcnow().isoformat()
        }

# Usage example
async def main():
    alert_manager = AlertManager('alert-config.json')
    
    # Create test alert
    alert = alert_manager.create_alert(
        "health_check_failed",
        "yandex",
        AlertSeverity.CRITICAL,
        "Health check failed for Yandex Cloud"
    )
    
    # Send notification
    await alert_manager.send_notification(alert)
    
    # Get alert summary
    summary = alert_manager.get_alert_summary()
    print(json.dumps(summary, indent=2))

if __name__ == "__main__":
    asyncio.run(main())
```

### Log Aggregation and Analysis
```python
# log_analyzer.py
import re
import json
import asyncio
from datetime import datetime, timedelta
from typing import Dict, List, Optional
from dataclasses import dataclass

@dataclass
class LogEntry:
    timestamp: datetime
    level: str
    message: str
    provider: str
    source: str
    metadata: Optional[Dict] = None

class LogAnalyzer:
    def __init__(self):
        self.log_patterns = {
            'error': re.compile(r'ERROR|error|Error'),
            'warning': re.compile(r'WARNING|warning|Warning'),
            'critical': re.compile(r'CRITICAL|critical|Critical'),
            'response_time': re.compile(r'response_time[:\s=]+(\d+(?:\.\d+)?)ms'),
            'status_code': re.compile(r'status_code[:\s=]+(\d{3})'),
            'provider': re.compile(r'(yandex|vk|selectel)', re.IGNORECASE)
        }
        
        self.logs: List[LogEntry] = []
        
    def parse_log_line(self, line: str, source: str = "unknown") -> Optional[LogEntry]:
        """Parse a single log line"""
        try:
            # Extract timestamp (simplified)
            timestamp_match = re.search(r'(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})', line)
            timestamp = datetime.fromisoformat(timestamp_match.group(1)) if timestamp_match else datetime.utcnow()
            
            # Extract log level
            level = "INFO"
            if self.log_patterns['critical'].search(line):
                level = "CRITICAL"
            elif self.log_patterns['error'].search(line):
                level = "ERROR"
            elif self.log_patterns['warning'].search(line):
                level = "WARNING"
            
            # Extract provider
            provider_match = self.log_patterns['provider'].search(line)
            provider = provider_match.group(1).lower() if provider_match else "unknown"
            
            return LogEntry(
                timestamp=timestamp,
                level=level,
                message=line.strip(),
                provider=provider,
                source=source
            )
        except Exception:
            return None
    
    def analyze_logs(self, time_window: timedelta = timedelta(hours=1)) -> Dict:
        """Analyze logs within a time window"""
        cutoff_time = datetime.utcnow() - time_window
        recent_logs = [log for log in self.logs if log.timestamp >= cutoff_time]
        
        analysis = {
            "time_window_hours": time_window.total_seconds() / 3600,
            "total_logs": len(recent_logs),
            "logs_by_level": {},
            "logs_by_provider": {},
            "error_rate": 0,
            "warning_rate": 0,
            "critical_events": [],
            "performance_metrics": {
                "average_response_time": 0,
                "response_times_by_provider": {}
            },
            "top_errors": []
        }
        
        # Count logs by level
        for log in recent_logs:
            analysis["logs_by_level"][log.level] = analysis["logs_by_level"].get(log.level, 0) + 1
            analysis["logs_by_provider"][log.provider] = analysis["logs_by_provider"].get(log.provider, 0) + 1
        
        # Calculate error and warning rates
        total_logs = len(recent_logs)
        if total_logs > 0:
            analysis["error_rate"] = analysis["logs_by_level"].get("ERROR", 0) / total_logs * 100
            analysis["warning_rate"] = analysis["logs_by_level"].get("WARNING", 0) / total_logs * 100
        
        # Extract critical events
        analysis["critical_events"] = [
            {
                "timestamp": log.timestamp.isoformat(),
                "message": log.message,
                "provider": log.provider
            }
            for log in recent_logs if log.level == "CRITICAL"
        ]
        
        # Extract performance metrics
        response_times = []
        response_times_by_provider = {}
        
        for log in recent_logs:
            response_match = self.log_patterns['response_time'].search(log.message)
            if response_match:
                response_time = float(response_match.group(1))
                response_times.append(response_time)
                
                if log.provider not in response_times_by_provider:
                    response_times_by_provider[log.provider] = []
                response_times_by_provider[log.provider].append(response_time)
        
        if response_times:
            analysis["performance_metrics"]["average_response_time"] = sum(response_times) / len(response_times)
            
            for provider, times in response_times_by_provider.items():
                if times:
                    analysis["performance_metrics"]["response_times_by_provider"][provider] = sum(times) / len(times)
        
        # Extract top errors
        error_logs = [log for log in recent_logs if log.level == "ERROR"]
        error_counts = {}
        
        for log in error_logs:
            # Simple error grouping by first 50 characters
            error_key = log.message[:50]
            error_counts[error_key] = error_counts.get(error_key, 0) + 1
        
        # Sort by count and take top 10
        sorted_errors = sorted(error_counts.items(), key=lambda x: x[1], reverse=True)[:10]
        analysis["top_errors"] = [
            {"message": key, "count": count} for key, count in sorted_errors
        ]
        
        return analysis
    
    def detect_anomalies(self, time_window: timedelta = timedelta(hours=1)) -> List[Dict]:
        """Detect anomalies in logs"""
        cutoff_time = datetime.utcnow() - time_window
        recent_logs = [log for log in self.logs if log.timestamp >= cutoff_time]
        
        anomalies = []
        
        # High error rate anomaly
        error_logs = [log for log in recent_logs if log.level == "ERROR"]
        error_rate = len(error_logs) / len(recent_logs) * 100 if recent_logs else 0
        
        if error_rate > 10:  # More than 10% errors
            anomalies.append({
                "type": "high_error_rate",
                "severity": "warning",
                "message": f"High error rate detected: {error_rate:.2f}%",
                "timestamp": datetime.utcnow().isoformat(),
                "details": {"error_rate": error_rate}
            })
        
        # Critical events anomaly
        critical_logs = [log for log in recent_logs if log.level == "CRITICAL"]
        if len(critical_logs) > 5:  # More than 5 critical events
            anomalies.append({
                "type": "high_critical_events",
                "severity": "critical",
                "message": f"High number of critical events: {len(critical_logs)}",
                "timestamp": datetime.utcnow().isoformat(),
                "details": {"critical_count": len(critical_logs)}
            })
        
        # Provider-specific anomalies
        provider_error_rates = {}
        for provider in set(log.provider for log in recent_logs):
            provider_logs = [log for log in recent_logs if log.provider == provider]
            provider_errors = [log for log in provider_logs if log.level == "ERROR"]
            provider_error_rate = len(provider_errors) / len(provider_logs) * 100 if provider_logs else 0
            provider_error_rates[provider] = provider_error_rate
            
            if provider_error_rate > 15:  # More than 15% errors for a provider
                anomalies.append({
                    "type": "provider_high_error_rate",
                    "severity": "warning",
                    "message": f"High error rate for {provider}: {provider_error_rate:.2f}%",
                    "timestamp": datetime.utcnow().isoformat(),
                    "details": {"provider": provider, "error_rate": provider_error_rate}
                })
        
        return anomalies

# Usage example
def main():
    analyzer = LogAnalyzer()
    
    # Add some sample logs
    sample_logs = [
        "2024-01-01T12:00:00 INFO Yandex Cloud: Request processed successfully",
        "2024-01-01T12:01:00 ERROR VK Cloud: Connection timeout response_time:5000ms",
        "2024-01-01T12:02:00 CRITICAL Selectel: Database connection failed",
        "2024-01-01T12:03:00 WARNING Yandex Cloud: High memory usage detected",
        "2024-01-01T12:04:00 ERROR VK Cloud: API rate limit exceeded status_code:429"
    ]
    
    for log in sample_logs:
        entry = analyzer.parse_log_line(log, "sample")
        if entry:
            analyzer.logs.append(entry)
    
    # Analyze logs
    analysis = analyzer.analyze_logs()
    print("Log Analysis:")
    print(json.dumps(analysis, indent=2))
    
    # Detect anomalies
    anomalies = analyzer.detect_anomalies()
    print("\nAnomalies:")
    print(json.dumps(anomalies, indent=2))

if __name__ == "__main__":
    main()
```

## Dashboard Configuration

### Grafana Dashboard Template
```json
{
  "dashboard": {
    "id": null,
    "title": "Russian Cloud Monitoring",
    "tags": ["russian-clouds", "monitoring"],
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "Provider Health Status",
        "type": "stat",
        "targets": [
          {
            "expr": "russian_cloud_health_status",
            "legendFormat": "{{provider}}"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "mappings": [
              {
                "options": {
                  "0": {
                    "text": "Unhealthy",
                    "color": "red"
                  },
                  "1": {
                    "text": "Healthy",
                    "color": "green"
                  }
                },
                "type": "value"
              }
            ]
          }
        }
      },
      {
        "id": 2,
        "title": "Response Time by Provider",
        "type": "graph",
        "targets": [
          {
            "expr": "russian_cloud_response_time_ms",
            "legendFormat": "{{provider}}"
          }
        ],
        "yAxes": [
          {
            "label": "Response Time (ms)"
          }
        ]
      },
      {
        "id": 3,
        "title": "Error Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(russian_cloud_errors_total[5m])",
            "legendFormat": "{{provider}}"
          }
        ],
        "yAxes": [
          {
            "label": "Errors per Second"
          }
        ]
      },
      {
        "id": 4,
        "title": "System Metrics",
        "type": "graph",
        "targets": [
          {
            "expr": "system_cpu_usage",
            "legendFormat": "CPU"
          },
          {
            "expr": "system_memory_usage",
            "legendFormat": "Memory"
          },
          {
            "expr": "system_disk_usage",
            "legendFormat": "Disk"
          }
        ]
      },
      {
        "id": 5,
        "title": "Alert Summary",
        "type": "table",
        "targets": [
          {
            "expr": "russian_cloud_alerts",
            "format": "table"
          }
        ],
        "columns": [
          {
            "text": "Provider"
          },
          {
            "text": "Severity"
          },
          {
            "text": "Message"
          },
          {
            "text": "Time"
          }
        ]
      }
    ],
    "time": {
      "from": "now-1h",
      "to": "now"
    },
    "refresh": "30s"
  }
}
```

## Usage Instructions

### Setup Monitoring System
```bash
# 1. Install dependencies
pip install aiohttp psutil

# 2. Configure monitoring
cp russian-clouds-config.json.template russian-clouds-config.json
cp alert-config.json.template alert-config.json

# 3. Start monitoring
python russian_cloud_monitoring.py

# 4. Start performance monitoring
python performance_monitor.py

# 5. Start log analysis
python log_analyzer.py
```

### Integration with CI/CD
```yaml
# Add to your CI/CD pipeline
- name: Russian Cloud Monitoring
  run: |
    python russian_cloud_monitoring.py --config russian-clouds-config.json
    python performance_monitor.py --urls "https://space-invaders.yandexcloud.net,https://space-invaders.vkcloud.com,https://space-invaders.selectel.ru"
```

This comprehensive monitoring system provides real-time monitoring, alerting, and analysis for all Russian cloud providers with automated anomaly detection and performance tracking.
