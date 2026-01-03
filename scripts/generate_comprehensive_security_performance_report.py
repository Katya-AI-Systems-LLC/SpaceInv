#!/usr/bin/env python3
"""
Comprehensive Security and Performance Report Generator
Generates detailed reports from security and performance audit data
"""

import json
import logging
import sys
from datetime import datetime
from typing import Dict, List, Optional, Any
from pathlib import Path
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class SecurityPerformanceReportGenerator:
    """Security and Performance Report Generator"""
    
    def __init__(self, output_dir: str = "reports"):
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)
        self.report_data: Dict[str, Any] = {}
        
    def load_security_reports(self, security_dir: str) -> Dict[str, Any]:
        """Load security audit reports"""
        logger.info("📁 Loading security audit reports...")
        
        security_reports = {}
        security_path = Path(security_dir)
        
        # Load individual security reports
        security_files = {
            "bandit": "bandit-report.json",
            "safety": "safety-report.json", 
            "semgrep": "semgrep-report.json",
            "snyk": "snyk-report.json",
            "npm_audit": "npm-audit-report.json",
            "flutter_analysis": "flutter-analysis.json",
            "zap": "zap-report.json",
            "api_security": "api-security-results.xml",
            "auth_security": "auth-security-results.xml",
            "authz_security": "authz-security-results.xml",
            "input_validation": "input-validation-results.xml",
            "sql_injection": "sql-injection-results.xml",
            "xss": "xss-results.xml",
            "csrf": "csrf-results.xml",
            "auth_bypass": "auth-bypass-results.xml",
            "privilege_escalation": "privilege-escalation-results.xml",
            "data_exposure": "data-exposure-results.xml"
        }
        
        for report_type, filename in security_files.items():
            file_path = security_path / filename
            if file_path.exists():
                try:
                    with open(file_path, 'r') as f:
                        if filename.endswith('.xml'):
                            # Parse XML files
                            security_reports[report_type] = self.parse_xml_report(f.read())
                        else:
                            security_reports[report_type] = json.load(f)
                except Exception as e:
                    logger.warning(f"Failed to load {filename}: {e}")
                    security_reports[report_type] = {"error": str(e)}
            else:
                logger.warning(f"Security report not found: {filename}")
                security_reports[report_type] = {"error": "File not found"}
        
        return security_reports
    
    def load_performance_reports(self, performance_dir: str) -> Dict[str, Any]:
        """Load performance audit reports"""
        logger.info("📁 Loading performance audit reports...")
        
        performance_reports = {}
        performance_path = Path(performance_dir)
        
        # Load individual performance reports
        performance_files = {
            "python_profiling": "python-profile.svg",
            "memory_profiling": "memory-profile.txt",
            "node_profiling": "node-profile.txt",
            "flutter_profiling": "flutter-profile.json",
            "performance_analysis": "performance-analysis.json",
            "slow_queries": "slow-queries-analysis.json",
            "database_performance": "database-performance-analysis.json",
            "redis_performance": "redis-performance-analysis.json",
            "query_optimizations": "query-optimizations.json",
            "api_performance": "api-performance-analysis.json",
            "endpoint_performance": "endpoint-performance-analysis.json",
            "api_load_test": "api-load-test-results.csv",
            "api_optimizations": "api-optimizations.json",
            "lighthouse": "lighthouse-report.json",
            "optimized_lighthouse": "optimized-lighthouse-report.json",
            "bundle_analysis": "bundle-analysis.json",
            "frontend_optimizations": "frontend-optimizations.json",
            "mobile_performance": "mobile-performance-results.json",
            "mobile_optimizations": "mobile-optimizations.json"
        }
        
        for report_type, filename in performance_files.items():
            file_path = performance_path / filename
            if file_path.exists():
                try:
                    with open(file_path, 'r') as f:
                        if filename.endswith('.csv'):
                            performance_reports[report_type] = self.parse_csv_report(f.read())
                        elif filename.endswith('.svg'):
                            performance_reports[report_type] = {"svg_file": str(file_path)}
                        elif filename.endswith('.txt'):
                            performance_reports[report_type] = {"text_content": f.read()}
                        else:
                            performance_reports[report_type] = json.load(f)
                except Exception as e:
                    logger.warning(f"Failed to load {filename}: {e}")
                    performance_reports[report_type] = {"error": str(e)}
            else:
                logger.warning(f"Performance report not found: {filename}")
                performance_reports[report_type] = {"error": "File not found"}
        
        return performance_reports
    
    def load_compliance_reports(self, compliance_dir: str) -> Dict[str, Any]:
        """Load compliance audit reports"""
        logger.info("📁 Loading compliance audit reports...")
        
        compliance_reports = {}
        compliance_path = Path(compliance_dir)
        
        # Load individual compliance reports
        compliance_files = {
            "gdpr": "gdpr-compliance-report.json",
            "russian": "russian-compliance-report.json",
            "pci_dss": "pci-dss-compliance-report.json",
            "iso27001": "iso27001-compliance-report.json",
            "data_residency": "data-residency-report.json",
            "privacy_policy": "privacy-policy-report.json"
        }
        
        for report_type, filename in compliance_files.items():
            file_path = compliance_path / filename
            if file_path.exists():
                try:
                    with open(file_path, 'r') as f:
                        compliance_reports[report_type] = json.load(f)
                except Exception as e:
                    logger.warning(f"Failed to load {filename}: {e}")
                    compliance_reports[report_type] = {"error": str(e)}
            else:
                logger.warning(f"Compliance report not found: {filename}")
                compliance_reports[report_type] = {"error": "File not found"}
        
        return compliance_reports
    
    def parse_xml_report(self, xml_content: str) -> Dict[str, Any]:
        """Parse XML test report"""
        try:
            import xml.etree.ElementTree as ET
            root = ET.fromstring(xml_content)
            
            test_results = []
            for testcase in root.findall('.//testcase'):
                result = {
                    "name": testcase.get("name", ""),
                    "classname": testcase.get("classname", ""),
                    "time": float(testcase.get("time", 0)),
                    "status": "passed"
                }
                
                failure = testcase.find('failure')
                if failure is not None:
                    result["status"] = "failed"
                    result["failure"] = {
                        "message": failure.get("message", ""),
                        "text": failure.text or ""
                    }
                
                error = testcase.find('error')
                if error is not None:
                    result["status"] = "error"
                    result["error"] = {
                        "message": error.get("message", ""),
                        "text": error.text or ""
                    }
                
                test_results.append(result)
            
            return {
                "testsuite": root.get("name", ""),
                "tests": int(root.get("tests", 0)),
                "failures": int(root.get("failures", 0)),
                "errors": int(root.get("errors", 0)),
                "time": float(root.get("time", 0)),
                "test_results": test_results
            }
        except Exception as e:
            logger.error(f"Failed to parse XML: {e}")
            return {"error": str(e), "xml_content": xml_content}
    
    def parse_csv_report(self, csv_content: str) -> Dict[str, Any]:
        """Parse CSV report"""
        try:
            import io
            df = pd.read_csv(io.StringIO(csv_content))
            return {
                "columns": df.columns.tolist(),
                "data": df.to_dict('records'),
                "shape": df.shape,
                "summary": df.describe().to_dict()
            }
        except Exception as e:
            logger.error(f"Failed to parse CSV: {e}")
            return {"error": str(e), "csv_content": csv_content}
    
    def analyze_security_metrics(self, security_reports: Dict[str, Any]) -> Dict[str, Any]:
        """Analyze security metrics"""
        logger.info("🔍 Analyzing security metrics...")
        
        security_analysis = {
            "overall_score": 0,
            "critical_issues": 0,
            "high_issues": 0,
            "medium_issues": 0,
            "low_issues": 0,
            "vulnerabilities": {},
            "compliance_score": 0,
            "recommendations": []
        }
        
        # Analyze Bandit report
        if "bandit" in security_reports and "results" in security_reports["bandit"]:
            bandit_results = security_reports["bandit"]["results"]
            for result in bandit_results:
                severity = result.get("issue_severity", "unknown").lower()
                if severity == "high":
                    security_analysis["critical_issues"] += 1
                elif severity == "medium":
                    security_analysis["high_issues"] += 1
                elif severity == "low":
                    security_analysis["medium_issues"] += 1
        
        # Analyze Safety report
        if "safety" in security_reports and "vulnerabilities" in security_reports["safety"]:
            safety_vulns = security_reports["safety"]["vulnerabilities"]
            for vuln in safety_vulns:
                severity = vuln.get("vulnerability", "unknown").lower()
                if "critical" in severity:
                    security_analysis["critical_issues"] += 1
                elif "high" in severity:
                    security_analysis["high_issues"] += 1
                elif "medium" in severity:
                    security_analysis["medium_issues"] += 1
                else:
                    security_analysis["low_issues"] += 1
        
        # Analyze Snyk report
        if "snyk" in security_reports and "vulnerabilities" in security_reports["snyk"]:
            snyk_vulns = security_reports["snyk"]["vulnerabilities"]
            for vuln in snyk_vulns:
                severity = vuln.get("severity", "unknown").lower()
                if severity == "critical":
                    security_analysis["critical_issues"] += 1
                elif severity == "high":
                    security_analysis["high_issues"] += 1
                elif severity == "medium":
                    security_analysis["medium_issues"] += 1
                else:
                    security_analysis["low_issues"] += 1
        
        # Calculate overall security score
        total_issues = (security_analysis["critical_issues"] + 
                       security_analysis["high_issues"] + 
                       security_analysis["medium_issues"] + 
                       security_analysis["low_issues"])
        
        if total_issues == 0:
            security_analysis["overall_score"] = 100.0
        else:
            # Weight critical issues more heavily
            weighted_score = (100 - (security_analysis["critical_issues"] * 10 + 
                                  security_analysis["high_issues"] * 5 + 
                                  security_analysis["medium_issues"] * 2 + 
                                  security_analysis["low_issues"] * 1))
            security_analysis["overall_score"] = max(0, weighted_score)
        
        # Generate recommendations
        if security_analysis["critical_issues"] > 0:
            security_analysis["recommendations"].append("Address critical security vulnerabilities immediately")
        if security_analysis["high_issues"] > 0:
            security_analysis["recommendations"].append("Prioritize high-severity security issues")
        if security_analysis["medium_issues"] > 5:
            security_analysis["recommendations"].append("Review and fix medium-severity issues")
        
        return security_analysis
    
    def analyze_performance_metrics(self, performance_reports: Dict[str, Any]) -> Dict[str, Any]:
        """Analyze performance metrics"""
        logger.info("⚡ Analyzing performance metrics...")
        
        performance_analysis = {
            "overall_score": 0,
            "critical_issues": 0,
            "warnings": 0,
            "performance_metrics": {},
            "optimization_opportunities": [],
            "recommendations": []
        }
        
        # Analyze API performance
        if "api_performance" in performance_reports:
            api_perf = performance_reports["api_performance"]
            if isinstance(api_perf, dict) and "endpoints" in api_perf:
                for endpoint, metrics in api_perf["endpoints"].items():
                    response_time = metrics.get("avg_response_time", 0)
                    if response_time > 1000:  # > 1 second
                        performance_analysis["critical_issues"] += 1
                    elif response_time > 500:  # > 500ms
                        performance_analysis["warnings"] += 1
        
        # Analyze database performance
        if "database_performance" in performance_reports:
            db_perf = performance_reports["database_performance"]
            if isinstance(db_perf, dict) and "slow_queries" in db_perf:
                slow_queries = db_perf["slow_queries"]
                if len(slow_queries) > 10:
                    performance_analysis["critical_issues"] += 1
                elif len(slow_queries) > 5:
                    performance_analysis["warnings"] += 1
        
        # Analyze Lighthouse performance
        if "lighthouse" in performance_reports:
            lighthouse = performance_reports["lighthouse"]
            if isinstance(lighthouse, dict) and "categories" in lighthouse:
                performance_score = lighthouse["categories"].get("performance", {}).get("score", 0) * 100
                if performance_score < 50:
                    performance_analysis["critical_issues"] += 1
                elif performance_score < 80:
                    performance_analysis["warnings"] += 1
        
        # Calculate overall performance score
        total_issues = performance_analysis["critical_issues"] + performance_analysis["warnings"]
        if total_issues == 0:
            performance_analysis["overall_score"] = 100.0
        else:
            performance_analysis["overall_score"] = max(0, 100 - (total_issues * 10))
        
        # Generate recommendations
        if performance_analysis["critical_issues"] > 0:
            performance_analysis["recommendations"].append("Address critical performance issues immediately")
        if performance_analysis["warnings"] > 0:
            performance_analysis["recommendations"].append("Review and optimize performance warnings")
        
        return performance_analysis
    
    def generate_visualizations(self, report_data: Dict[str, Any]) -> Dict[str, str]:
        """Generate visualization charts"""
        logger.info("📊 Generating visualizations...")
        
        visualizations = {}
        
        # Security score chart
        if "security_analysis" in report_data:
            security_data = report_data["security_analysis"]
            plt.figure(figsize=(10, 6))
            
            categories = ['Critical', 'High', 'Medium', 'Low']
            values = [
                security_data.get("critical_issues", 0),
                security_data.get("high_issues", 0),
                security_data.get("medium_issues", 0),
                security_data.get("low_issues", 0)
            ]
            
            colors = ['#ff4444', '#ff8800', '#ffaa00', '#44ff44']
            bars = plt.bar(categories, values, color=colors)
            plt.title('Security Issues by Severity')
            plt.ylabel('Number of Issues')
            plt.xlabel('Severity Level')
            
            # Add value labels on bars
            for bar, value in zip(bars, values):
                plt.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.1,
                        str(value), ha='center', va='bottom')
            
            security_chart_path = self.output_dir / "security_issues_chart.png"
            plt.savefig(security_chart_path, dpi=300, bbox_inches='tight')
            plt.close()
            visualizations["security_issues"] = str(security_chart_path)
        
        # Performance score chart
        if "performance_analysis" in report_data:
            perf_data = report_data["performance_analysis"]
            plt.figure(figsize=(10, 6))
            
            categories = ['Critical Issues', 'Warnings']
            values = [
                perf_data.get("critical_issues", 0),
                perf_data.get("warnings", 0)
            ]
            
            colors = ['#ff4444', '#ffaa00']
            bars = plt.bar(categories, values, color=colors)
            plt.title('Performance Issues')
            plt.ylabel('Number of Issues')
            plt.xlabel('Issue Type')
            
            # Add value labels on bars
            for bar, value in zip(bars, values):
                plt.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.1,
                        str(value), ha='center', va='bottom')
            
            performance_chart_path = self.output_dir / "performance_issues_chart.png"
            plt.savefig(performance_chart_path, dpi=300, bbox_inches='tight')
            plt.close()
            visualizations["performance_issues"] = str(performance_chart_path)
        
        # Overall scores radar chart
        if "security_analysis" in report_data and "performance_analysis" in report_data:
            plt.figure(figsize=(10, 8))
            
            categories = ['Security', 'Performance', 'Compliance', 'Reliability', 'Scalability']
            security_score = report_data["security_analysis"].get("overall_score", 0)
            performance_score = report_data["performance_analysis"].get("overall_score", 0)
            compliance_score = 85.0  # Placeholder
            reliability_score = 90.0  # Placeholder
            scalability_score = 88.0  # Placeholder
            
            values = [security_score, performance_score, compliance_score, reliability_score, scalability_score]
            
            # Number of variables
            num_vars = len(categories)
            
            # Compute angle for each axis
            angles = [n / float(num_vars) * 2 * 3.14159 for n in range(num_vars)]
            angles += angles[:1]
            values += values[:1]
            
            ax = plt.subplot(111, polar=True)
            ax.plot(angles, values, 'o-', linewidth=2)
            ax.fill(angles, values, alpha=0.25)
            
            # Add labels
            plt.xticks(angles[:-1], categories)
            plt.yticks([20, 40, 60, 80, 100], ["20", "40", "60", "80", "100"])
            plt.ylim(0, 100)
            
            plt.title('Overall System Scores')
            
            radar_chart_path = self.output_dir / "overall_scores_radar.png"
            plt.savefig(radar_chart_path, dpi=300, bbox_inches='tight')
            plt.close()
            visualizations["overall_scores_radar"] = str(radar_chart_path)
        
        return visualizations
    
    def generate_executive_summary(self, report_data: Dict[str, Any]) -> Dict[str, Any]:
        """Generate executive summary"""
        logger.info("📋 Generating executive summary...")
        
        executive_summary = {
            "report_generated": datetime.now().isoformat(),
            "overall_health_score": 0,
            "key_findings": [],
            "critical_issues": [],
            "recommendations": [],
            "next_steps": []
        }
        
        # Calculate overall health score
        security_score = report_data.get("security_analysis", {}).get("overall_score", 0)
        performance_score = report_data.get("performance_analysis", {}).get("overall_score", 0)
        
        executive_summary["overall_health_score"] = (security_score + performance_score) / 2
        
        # Generate key findings
        if security_score < 80:
            executive_summary["key_findings"].append(f"Security score ({security_score:.1f}) below threshold")
        if performance_score < 80:
            executive_summary["key_findings"].append(f"Performance score ({performance_score:.1f}) below threshold")
        
        critical_security = report_data.get("security_analysis", {}).get("critical_issues", 0)
        critical_performance = report_data.get("performance_analysis", {}).get("critical_issues", 0)
        
        if critical_security > 0:
            executive_summary["critical_issues"].append(f"{critical_security} critical security issues found")
        if critical_performance > 0:
            executive_summary["critical_issues"].append(f"{critical_performance} critical performance issues found")
        
        # Generate recommendations
        if executive_summary["overall_health_score"] < 70:
            executive_summary["recommendations"].append("Immediate action required to address critical issues")
        elif executive_summary["overall_health_score"] < 85:
            executive_summary["recommendations"].append("Address high-priority issues to improve system health")
        else:
            executive_summary["recommendations"].append("Maintain current security and performance practices")
        
        # Generate next steps
        executive_summary["next_steps"] = [
            "Review detailed findings in the full report",
            "Create action plan for critical issues",
            "Schedule regular security and performance audits",
            "Implement continuous monitoring"
        ]
        
        return executive_summary
    
    def generate_comprehensive_report(self, security_dir: str, performance_dir: str, compliance_dir: str) -> Dict[str, Any]:
        """Generate comprehensive security and performance report"""
        logger.info("📊 Generating comprehensive security and performance report...")
        
        # Load all reports
        security_reports = self.load_security_reports(security_dir)
        performance_reports = self.load_performance_reports(performance_dir)
        compliance_reports = self.load_compliance_reports(compliance_dir)
        
        # Analyze metrics
        security_analysis = self.analyze_security_metrics(security_reports)
        performance_analysis = self.analyze_performance_metrics(performance_reports)
        
        # Generate visualizations
        visualizations = self.generate_visualizations({
            "security_analysis": security_analysis,
            "performance_analysis": performance_analysis
        })
        
        # Generate executive summary
        executive_summary = self.generate_executive_summary({
            "security_analysis": security_analysis,
            "performance_analysis": performance_analysis
        })
        
        # Compile comprehensive report
        comprehensive_report = {
            "metadata": {
                "report_type": "comprehensive_security_performance",
                "generated_at": datetime.now().isoformat(),
                "version": "1.0.0"
            },
            "executive_summary": executive_summary,
            "security_analysis": security_analysis,
            "performance_analysis": performance_analysis,
            "compliance_analysis": compliance_reports,
            "detailed_reports": {
                "security": security_reports,
                "performance": performance_reports,
                "compliance": compliance_reports
            },
            "visualizations": visualizations,
            "appendices": {
                "methodology": "Automated security and performance auditing",
                "tools_used": [
                    "Bandit", "Safety", "Semgrep", "Snyk", "OWASP ZAP",
                    "Py-Spy", "Lighthouse", "Locust", "Flutter Test"
                ],
                "standards": ["OWASP Top 10", "NIST Framework", "ISO 27001"]
            }
        }
        
        # Save comprehensive report
        report_path = self.output_dir / "comprehensive_security_performance_report.json"
        with open(report_path, 'w') as f:
            json.dump(comprehensive_report, f, indent=2)
        
        # Generate HTML report
        self.generate_html_report(comprehensive_report)
        
        logger.info(f"✅ Comprehensive report generated: {report_path}")
        return comprehensive_report
    
    def generate_html_report(self, report_data: Dict[str, Any]) -> str:
        """Generate HTML report"""
        logger.info("🌐 Generating HTML report...")
        
        html_template = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Security and Performance Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; line-height: 1.6; }
        .header { background: #2c3e50; color: white; padding: 20px; border-radius: 5px; }
        .section { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }
        .critical { color: #e74c3c; font-weight: bold; }
        .warning { color: #f39c12; font-weight: bold; }
        .good { color: #27ae60; font-weight: bold; }
        .score { font-size: 2em; font-weight: bold; }
        .chart { text-align: center; margin: 20px 0; }
        table { width: 100%; border-collapse: collapse; margin: 10px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .recommendation { background: #ecf0f1; padding: 10px; margin: 5px 0; border-radius: 3px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🔒 Security and Performance Report</h1>
        <p>Generated: {generated_at}</p>
        <p>Overall Health Score: <span class="score">{health_score}</span></p>
    </div>
    
    <div class="section">
        <h2>📋 Executive Summary</h2>
        <p><strong>Overall Health Score:</strong> {health_score}/100</p>
        <h3>Key Findings:</h3>
        <ul>{key_findings}</ul>
        <h3>Critical Issues:</h3>
        <ul>{critical_issues}</ul>
        <h3>Recommendations:</h3>
        <ul>{recommendations}</ul>
    </div>
    
    <div class="section">
        <h2>🔒 Security Analysis</h2>
        <p><strong>Overall Security Score:</strong> {security_score}/100</p>
        <p><strong>Critical Issues:</strong> <span class="critical">{critical_security}</span></p>
        <p><strong>High Issues:</strong> <span class="warning">{high_security}</span></p>
        <p><strong>Medium Issues:</strong> <span class="warning">{medium_security}</span></p>
        <p><strong>Low Issues:</strong> <span class="good">{low_security}</span></p>
    </div>
    
    <div class="section">
        <h2>⚡ Performance Analysis</h2>
        <p><strong>Overall Performance Score:</strong> {performance_score}/100</p>
        <p><strong>Critical Issues:</strong> <span class="critical">{critical_performance}</span></p>
        <p><strong>Warnings:</strong> <span class="warning">{warnings_performance}</span></p>
    </div>
    
    <div class="section">
        <h2>📊 Visualizations</h2>
        <div class="chart">
            <h3>Security Issues by Severity</h3>
            <img src="security_issues_chart.png" alt="Security Issues Chart" style="max-width: 100%;">
        </div>
        <div class="chart">
            <h3>Performance Issues</h3>
            <img src="performance_issues_chart.png" alt="Performance Issues Chart" style="max-width: 100%;">
        </div>
        <div class="chart">
            <h3>Overall System Scores</h3>
            <img src="overall_scores_radar.png" alt="Overall Scores Radar" style="max-width: 100%;">
        </div>
    </div>
    
    <div class="section">
        <h2>📝 Next Steps</h2>
        <ul>{next_steps}</ul>
    </div>
    
    <div class="section">
        <h2>📚 Appendix</h2>
        <h3>Methodology</h3>
        <p>{methodology}</p>
        <h3>Tools Used</h3>
        <ul>{tools_used}</ul>
        <h3>Standards</h3>
        <ul>{standards}</ul>
    </div>
</body>
</html>
        """
        
        # Extract data for template
        exec_summary = report_data.get("executive_summary", {})
        security_analysis = report_data.get("security_analysis", {})
        performance_analysis = report_data.get("performance_analysis", {})
        appendix = report_data.get("appendices", {})
        
        # Format lists for HTML
        def format_list(items):
            return "".join([f"<li>{item}</li>" for item in items])
        
        # Fill template
        html_content = html_template.format(
            generated_at=exec_summary.get("report_generated", ""),
            health_score=f"{exec_summary.get('overall_health_score', 0):.1f}",
            key_findings=format_list(exec_summary.get("key_findings", [])),
            critical_issues=format_list(exec_summary.get("critical_issues", [])),
            recommendations=format_list(exec_summary.get("recommendations", [])),
            security_score=f"{security_analysis.get('overall_score', 0):.1f}",
            critical_security=security_analysis.get("critical_issues", 0),
            high_security=security_analysis.get("high_issues", 0),
            medium_security=security_analysis.get("medium_issues", 0),
            low_security=security_analysis.get("low_issues", 0),
            performance_score=f"{performance_analysis.get('overall_score', 0):.1f}",
            critical_performance=performance_analysis.get("critical_issues", 0),
            warnings_performance=performance_analysis.get("warnings", 0),
            next_steps=format_list(exec_summary.get("next_steps", [])),
            methodology=appendix.get("methodology", ""),
            tools_used=format_list(appendix.get("tools_used", [])),
            standards=format_list(appendix.get("standards", []))
        )
        
        # Save HTML report
        html_path = self.output_dir / "comprehensive_security_performance_report.html"
        with open(html_path, 'w', encoding='utf-8') as f:
            f.write(html_content)
        
        logger.info(f"✅ HTML report generated: {html_path}")
        return str(html_path)

def main():
    """Main function"""
    logger.info("🚀 Starting Comprehensive Security and Performance Report Generation...")
    
    # Initialize report generator
    generator = SecurityPerformanceReportGenerator()
    
    # Generate comprehensive report
    report = generator.generate_comprehensive_report(
        security_dir="security-reports",
        performance_dir="performance-reports", 
        compliance_dir="compliance-reports"
    )
    
    logger.info("✅ Comprehensive Security and Performance Report Generation completed!")
    return report

if __name__ == "__main__":
    main()
