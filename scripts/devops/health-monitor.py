#!/usr/bin/env python3
"""
DevOps Health Monitoring Script
Comprehensive health monitoring for applications, databases, and infrastructure
"""

import os
import sys
import json
import time
import requests
import logging
import argparse
import subprocess
from datetime import datetime
from typing import Dict, List, Optional, Any
from dataclasses import dataclass
from pathlib import Path
import psutil
import socket

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('devops-health-monitor.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

@dataclass
class HealthCheck:
    """Health check configuration"""
    name: str
    url: str
    method: str = "GET"
    expected_status: int = 200
    timeout: int = 10
    headers: Optional[Dict[str, str]] = None
    check_interval: int = 60

@dataclass
class HealthResult:
    """Health check result"""
    name: str
    status: str
    response_time: float
    status_code: Optional[int] = None
    error_message: Optional[str] = None
    timestamp: datetime = None

class DevOpsHealthMonitor:
    """DevOps Health Monitoring System"""
    
    def __init__(self, config_file: str = None, environment: str = "production"):
        self.environment = environment
        self.config_file = config_file or f"monitoring/health-config-{environment}.json"
        self.health_checks: List[HealthCheck] = []
        self.results: List[HealthResult] = []
        self.load_config()
        
    def load_config(self):
        """Load health check configuration"""
        try:
            config_path = Path(self.config_file)
            if config_path.exists():
                with open(config_path, 'r') as f:
                    config = json.load(f)
                
                for check_config in config.get('health_checks', []):
                    self.health_checks.append(HealthCheck(**check_config))
                logger.info(f"Loaded {len(self.health_checks)} health checks from {self.config_file}")
            else:
                logger.warning(f"Config file {self.config_file} not found, using defaults")
                self.setup_default_checks()
        except Exception as e:
            logger.error(f"Failed to load config: {e}")
            self.setup_default_checks()
    
    def setup_default_checks(self):
        """Setup default health checks"""
        default_checks = [
            HealthCheck(
                name="frontend",
                url="http://localhost:80/health",
                method="GET",
                expected_status=200
            ),
            HealthCheck(
                name="api",
                url="http://localhost:8080/health",
                method="GET",
                expected_status=200
            ),
            HealthCheck(
                name="database",
                url="http://localhost:5432/health",
                method="GET",
                expected_status=200
            ),
            HealthCheck(
                name="redis",
                url="http://localhost:6379/health",
                method="GET",
                expected_status=200
            )
        ]
        self.health_checks = default_checks
    
    def check_http_endpoint(self, check: HealthCheck) -> HealthResult:
        """Check HTTP endpoint health"""
        start_time = time.time()
        
        try:
            headers = check.headers or {}
            response = requests.request(
                method=check.method,
                url=check.url,
                headers=headers,
                timeout=check.timeout
            )
            
            response_time = time.time() - start_time
            status = "healthy" if response.status_code == check.expected_status else "unhealthy"
            
            return HealthResult(
                name=check.name,
                status=status,
                response_time=response_time,
                status_code=response.status_code,
                timestamp=datetime.now()
            )
            
        except requests.exceptions.Timeout:
            response_time = time.time() - start_time
            return HealthResult(
                name=check.name,
                status="timeout",
                response_time=response_time,
                error_message="Request timeout",
                timestamp=datetime.now()
            )
        except requests.exceptions.ConnectionError:
            response_time = time.time() - start_time
            return HealthResult(
                name=check.name,
                status="connection_error",
                response_time=response_time,
                error_message="Connection error",
                timestamp=datetime.now()
            )
        except Exception as e:
            response_time = time.time() - start_time
            return HealthResult(
                name=check.name,
                status="error",
                response_time=response_time,
                error_message=str(e),
                timestamp=datetime.now()
            )
    
    def check_database_health(self) -> HealthResult:
        """Check database health"""
        try:
            # PostgreSQL health check
            result = subprocess.run(
                ["pg_isready", "-h", "localhost", "-p", "5432"],
                capture_output=True,
                text=True,
                timeout=10
            )
            
            if result.returncode == 0:
                return HealthResult(
                    name="database",
                    status="healthy",
                    response_time=0.1,
                    timestamp=datetime.now()
                )
            else:
                return HealthResult(
                    name="database",
                    status="unhealthy",
                    response_time=0.1,
                    error_message=result.stderr,
                    timestamp=datetime.now()
                )
        except subprocess.TimeoutExpired:
            return HealthResult(
                name="database",
                status="timeout",
                response_time=10.0,
                error_message="Database check timeout",
                timestamp=datetime.now()
            )
        except Exception as e:
            return HealthResult(
                name="database",
                status="error",
                response_time=0.1,
                error_message=str(e),
                timestamp=datetime.now()
            )
    
    def check_redis_health(self) -> HealthResult:
        """Check Redis health"""
        try:
            import redis
            r = redis.Redis(host='localhost', port=6379, db=0)
            r.ping()
            
            return HealthResult(
                name="redis",
                status="healthy",
                response_time=0.05,
                timestamp=datetime.now()
            )
        except Exception as e:
            return HealthResult(
                name="redis",
                status="unhealthy",
                response_time=0.1,
                error_message=str(e),
                timestamp=datetime.now()
            )
    
    def check_system_resources(self) -> Dict[str, Any]:
        """Check system resources"""
        try:
            cpu_percent = psutil.cpu_percent(interval=1)
            memory = psutil.virtual_memory()
            disk = psutil.disk_usage('/')
            
            return {
                "cpu_percent": cpu_percent,
                "memory_percent": memory.percent,
                "memory_available": memory.available,
                "disk_percent": disk.percent,
                "disk_free": disk.free,
                "load_average": os.getloadavg() if hasattr(os, 'getloadavg') else None
            }
        except Exception as e:
            logger.error(f"Failed to check system resources: {e}")
            return {}
    
    def check_network_connectivity(self) -> Dict[str, Any]:
        """Check network connectivity"""
        results = {}
        
        # Check DNS resolution
        try:
            socket.gethostbyname('google.com')
            results['dns'] = 'healthy'
        except Exception as e:
            results['dns'] = f'unhealthy: {str(e)}'
        
        # Check external connectivity
        try:
            response = requests.get('https://www.google.com', timeout=5)
            results['external'] = 'healthy' if response.status_code == 200 else 'unhealthy'
        except Exception as e:
            results['external'] = f'unhealthy: {str(e)}'
        
        # Check internal connectivity
        try:
            response = requests.get('http://localhost:80', timeout=5)
            results['internal'] = 'healthy' if response.status_code == 200 else 'unhealthy'
        except Exception as e:
            results['internal'] = f'unhealthy: {str(e)}'
        
        return results
    
    def run_health_checks(self) -> List[HealthResult]:
        """Run all health checks"""
        logger.info("Starting health checks...")
        results = []
        
        # Run HTTP endpoint checks
        for check in self.health_checks:
            logger.info(f"Checking {check.name}...")
            result = self.check_http_endpoint(check)
            results.append(result)
            logger.info(f"{check.name}: {result.status} ({result.response_time:.3f}s)")
        
        # Run database checks
        logger.info("Checking database...")
        db_result = self.check_database_health()
        results.append(db_result)
        logger.info(f"Database: {db_result.status}")
        
        # Run Redis checks
        logger.info("Checking Redis...")
        redis_result = self.check_redis_health()
        results.append(redis_result)
        logger.info(f"Redis: {redis_result.status}")
        
        self.results = results
        return results
    
    def generate_health_report(self) -> Dict[str, Any]:
        """Generate comprehensive health report"""
        system_resources = self.check_system_resources()
        network_connectivity = self.check_network_connectivity()
        
        # Calculate overall health
        healthy_count = sum(1 for r in self.results if r.status == "healthy")
        total_count = len(self.results)
        overall_health = "healthy" if healthy_count == total_count else "degraded" if healthy_count > 0 else "unhealthy"
        
        report = {
            "timestamp": datetime.now().isoformat(),
            "environment": self.environment,
            "overall_health": overall_health,
            "healthy_services": healthy_count,
            "total_services": total_count,
            "health_percentage": (healthy_count / total_count) * 100,
            "services": [
                {
                    "name": r.name,
                    "status": r.status,
                    "response_time": r.response_time,
                    "status_code": r.status_code,
                    "error_message": r.error_message,
                    "timestamp": r.timestamp.isoformat() if r.timestamp else None
                }
                for r in self.results
            ],
            "system_resources": system_resources,
            "network_connectivity": network_connectivity,
            "alerts": self.generate_alerts()
        }
        
        return report
    
    def generate_alerts(self) -> List[Dict[str, Any]]:
        """Generate alerts based on health check results"""
        alerts = []
        
        for result in self.results:
            if result.status != "healthy":
                alert = {
                    "service": result.name,
                    "severity": "critical" if result.status in ["timeout", "connection_error"] else "warning",
                    "message": f"Service {result.name} is {result.status}",
                    "details": result.error_message or f"Status code: {result.status_code}",
                    "timestamp": result.timestamp.isoformat() if result.timestamp else None
                }
                alerts.append(alert)
        
        # Check system resources
        system_resources = self.check_system_resources()
        if system_resources.get('cpu_percent', 0) > 80:
            alerts.append({
                "service": "system",
                "severity": "warning",
                "message": "High CPU usage detected",
                "details": f"CPU usage: {system_resources['cpu_percent']}%",
                "timestamp": datetime.now().isoformat()
            })
        
        if system_resources.get('memory_percent', 0) > 85:
            alerts.append({
                "service": "system",
                "severity": "warning",
                "message": "High memory usage detected",
                "details": f"Memory usage: {system_resources['memory_percent']}%",
                "timestamp": datetime.now().isoformat()
            })
        
        if system_resources.get('disk_percent', 0) > 90:
            alerts.append({
                "service": "system",
                "severity": "critical",
                "message": "Low disk space detected",
                "details": f"Disk usage: {system_resources['disk_percent']}%",
                "timestamp": datetime.now().isoformat()
            })
        
        return alerts
    
    def save_report(self, report: Dict[str, Any], output_file: str):
        """Save health report to file"""
        try:
            with open(output_file, 'w') as f:
                json.dump(report, f, indent=2)
            logger.info(f"Health report saved to {output_file}")
        except Exception as e:
            logger.error(f"Failed to save report: {e}")
    
    def send_slack_notification(self, report: Dict[str, Any], webhook_url: str):
        """Send health report to Slack"""
        try:
            if not webhook_url:
                logger.warning("Slack webhook URL not provided")
                return
            
            # Create Slack message
            color = "good" if report["overall_health"] == "healthy" else "warning" if report["overall_health"] == "degraded" else "danger"
            
            message = {
                "text": f"Health Report - {report['environment'].upper()}",
                "attachments": [
                    {
                        "color": color,
                        "fields": [
                            {
                                "title": "Overall Health",
                                "value": report["overall_health"].upper(),
                                "short": True
                            },
                            {
                                "title": "Health Percentage",
                                "value": f"{report['health_percentage']:.1f}%",
                                "short": True
                            },
                            {
                                "title": "Healthy Services",
                                "value": f"{report['healthy_services']}/{report['total_services']}",
                                "short": True
                            },
                            {
                                "title": "Timestamp",
                                "value": report["timestamp"],
                                "short": True
                            }
                        ]
                    }
                ]
            }
            
            # Add alerts if any
            if report["alerts"]:
                alert_text = "\n".join([f"• {alert['severity'].upper()}: {alert['message']}" for alert in report["alerts"][:5]])
                message["attachments"][0]["fields"].append({
                    "title": "Alerts",
                    "value": alert_text,
                    "short": False
                })
            
            response = requests.post(webhook_url, json=message, timeout=10)
            response.raise_for_status()
            logger.info("Slack notification sent successfully")
            
        except Exception as e:
            logger.error(f"Failed to send Slack notification: {e}")
    
    def monitor_continuously(self, interval: int = 60, output_file: str = None, slack_webhook: str = None):
        """Monitor health continuously"""
        logger.info(f"Starting continuous monitoring with {interval}s interval")
        
        try:
            while True:
                # Run health checks
                results = self.run_health_checks()
                
                # Generate report
                report = self.generate_health_report()
                
                # Save report
                if output_file:
                    self.save_report(report, output_file)
                
                # Send Slack notification if there are alerts
                if slack_webhook and report["alerts"]:
                    self.send_slack_notification(report, slack_webhook)
                
                # Log summary
                logger.info(f"Health check completed: {report['overall_health']} ({report['health_percentage']:.1f}%)")
                
                # Wait for next interval
                time.sleep(interval)
                
        except KeyboardInterrupt:
            logger.info("Monitoring stopped by user")
        except Exception as e:
            logger.error(f"Monitoring error: {e}")
            raise

def main():
    """Main function"""
    parser = argparse.ArgumentParser(description="DevOps Health Monitor")
    parser.add_argument("--environment", default="production", help="Environment name")
    parser.add_argument("--config", help="Configuration file path")
    parser.add_argument("--output", default="health-report.json", help="Output file path")
    parser.add_argument("--slack-webhook", help="Slack webhook URL")
    parser.add_argument("--continuous", action="store_true", help="Run continuous monitoring")
    parser.add_argument("--interval", type=int, default=60, help="Monitoring interval in seconds")
    parser.add_argument("--verbose", action="store_true", help="Enable verbose logging")
    
    args = parser.parse_args()
    
    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)
    
    # Create monitor
    monitor = DevOpsHealthMonitor(args.config, args.environment)
    
    if args.continuous:
        # Run continuous monitoring
        monitor.monitor_continuously(args.interval, args.output, args.slack_webhook)
    else:
        # Run single health check
        results = monitor.run_health_checks()
        report = monitor.generate_health_report()
        
        # Save report
        monitor.save_report(report, args.output)
        
        # Send Slack notification
        if args.slack_webhook:
            monitor.send_slack_notification(report, args.slack_webhook)
        
        # Print summary
        print(f"Health Check Results:")
        print(f"Overall Health: {report['overall_health']}")
        print(f"Health Percentage: {report['health_percentage']:.1f}%")
        print(f"Healthy Services: {report['healthy_services']}/{report['total_services']}")
        
        if report["alerts"]:
            print(f"\nAlerts:")
            for alert in report["alerts"]:
                print(f"  - {alert['severity'].upper()}: {alert['message']}")

if __name__ == "__main__":
    main()
