#!/usr/bin/env python3
"""
Security and Compliance Automation Script
Comprehensive security scanning, compliance checking, and reporting automation
"""

import os
import sys
import json
import time
import logging
import argparse
import subprocess
import requests
from datetime import datetime
from typing import Dict, List, Optional, Any
from pathlib import Path
import yaml
import jinja2
import weasyprint
from dataclasses import dataclass
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('security-compliance-automation.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

@dataclass
class SecurityScan:
    """Security scan configuration"""
    name: str
    tool: str
    command: str
    output_format: str
    severity_threshold: str
    enabled: bool

@dataclass
class ComplianceFramework:
    """Compliance framework configuration"""
    name: str
    description: str
    requirements: List[str]
    controls: List[str]
    enabled: bool

class SecurityComplianceAutomation:
    """Security and Compliance Automation System"""
    
    def __init__(self, config_file: str = None, environment: str = "production"):
        self.environment = environment
        self.config_file = config_file or "security-compliance-config.json"
        self.config = self.load_config()
        self.results = {}
        
    def load_config(self) -> Dict[str, Any]:
        """Load security and compliance configuration"""
        try:
            config_path = Path(self.config_file)
            if config_path.exists():
                with open(config_path, 'r') as f:
                    return json.load(f)
            else:
                logger.warning(f"Config file {self.config_file} not found, using defaults")
                return self.get_default_config()
        except Exception as e:
            logger.error(f"Failed to load config: {e}")
            return self.get_default_config()
    
    def get_default_config(self) -> Dict[str, Any]:
        """Get default configuration"""
        return {
            "security_scans": [
                {
                    "name": "sast",
                    "tool": "bandit",
                    "command": "bandit -r src/ -f json -o bandit-report.json",
                    "output_format": "json",
                    "severity_threshold": "medium",
                    "enabled": True
                },
                {
                    "name": "dependency",
                    "tool": "safety",
                    "command": "safety check --json --output safety-report.json",
                    "output_format": "json",
                    "severity_threshold": "high",
                    "enabled": True
                },
                {
                    "name": "container",
                    "tool": "trivy",
                    "command": "trivy image --format json --output trivy-report.json spaceinvaders:latest",
                    "output_format": "json",
                    "severity_threshold": "medium",
                    "enabled": True
                },
                {
                    "name": "infrastructure",
                    "tool": "checkov",
                    "command": "checkov -d terraform/ --framework terraform --output json --output-file-path checkov-report",
                    "output_format": "json",
                    "severity_threshold": "medium",
                    "enabled": True
                }
            ],
            "compliance_frameworks": [
                {
                    "name": "GDPR",
                    "description": "General Data Protection Regulation",
                    "requirements": [
                        "Lawful basis for processing",
                        "Data subject rights",
                        "Data protection impact assessment",
                        "Data breach notification"
                    ],
                    "controls": [
                        "Consent management",
                        "Data minimization",
                        "Encryption at rest and in transit",
                        "Access control"
                    ],
                    "enabled": True
                },
                {
                    "name": "SOC2",
                    "description": "Service Organization Control 2",
                    "requirements": [
                        "Security",
                        "Availability",
                        "Processing integrity",
                        "Confidentiality",
                        "Privacy"
                    ],
                    "controls": [
                        "Access control",
                        "Security monitoring",
                        "Incident response",
                        "Change management"
                    ],
                    "enabled": True
                },
                {
                    "name": "ISO27001",
                    "description": "Information Security Management",
                    "requirements": [
                        "Information security policy",
                        "Risk assessment",
                        "Control objectives",
                        "Statement of applicability"
                    ],
                    "controls": [
                        "Security policy",
                        "Risk management",
                        "Access control",
                        "Physical security"
                    ],
                    "enabled": True
                }
            ],
            "reporting": {
                "executive_template": "templates/executive-security-report.html",
                "technical_template": "templates/technical-security-report.html",
                "compliance_template": "templates/compliance-report.html",
                "output_dir": "reports",
                "pdf_output": True
            },
            "notifications": {
                "slack_webhook": os.getenv("SLACK_SECURITY_WEBHOOK", ""),
                "email_enabled": True,
                "email_recipients": ["security@space-invaders.local"],
                "smtp_server": "smtp.space-invaders.local",
                "smtp_port": 587,
                "smtp_username": "security@space-invaders.local",
                "smtp_password": os.getenv("SMTP_PASSWORD", "")
            }
        }
    
    def run_security_scans(self) -> Dict[str, Any]:
        """Run all security scans"""
        logger.info("Starting security scans...")
        scan_results = {}
        
        for scan_config in self.config["security_scans"]:
            if not scan_config["enabled"]:
                continue
                
            logger.info(f"Running {scan_config['name']} scan with {scan_config['tool']}...")
            
            try:
                result = self.run_single_scan(scan_config)
                scan_results[scan_config["name"]] = result
                logger.info(f"{scan_config['name']} scan completed")
                
            except Exception as e:
                logger.error(f"Failed to run {scan_config['name']} scan: {e}")
                scan_results[scan_config["name"]] = {
                    "status": "error",
                    "error": str(e),
                    "timestamp": datetime.now().isoformat()
                }
        
        self.results["security_scans"] = scan_results
        return scan_results
    
    def run_single_scan(self, scan_config: Dict[str, Any]) -> Dict[str, Any]:
        """Run a single security scan"""
        start_time = time.time()
        
        try:
            # Run the scan command
            result = subprocess.run(
                scan_config["command"],
                shell=True,
                capture_output=True,
                text=True,
                timeout=1800  # 30 minutes timeout
            )
            
            execution_time = time.time() - start_time
            
            # Parse results based on output format
            if scan_config["output_format"] == "json":
                try:
                    with open("bandit-report.json", "r") as f:
                        scan_data = json.load(f)
                except FileNotFoundError:
                    scan_data = {}
            else:
                scan_data = {"output": result.stdout}
            
            # Calculate metrics
            vulnerabilities = self.extract_vulnerabilities(scan_data, scan_config["tool"])
            
            return {
                "status": "success",
                "tool": scan_config["tool"],
                "command": scan_config["command"],
                "execution_time": execution_time,
                "vulnerabilities": vulnerabilities,
                "severity_threshold": scan_config["severity_threshold"],
                "timestamp": datetime.now().isoformat(),
                "raw_output": result.stdout,
                "error_output": result.stderr
            }
            
        except subprocess.TimeoutExpired:
            return {
                "status": "timeout",
                "tool": scan_config["tool"],
                "command": scan_config["command"],
                "execution_time": time.time() - start_time,
                "error": "Scan timed out",
                "timestamp": datetime.now().isoformat()
            }
    
    def extract_vulnerabilities(self, scan_data: Dict[str, Any], tool: str) -> Dict[str, Any]:
        """Extract vulnerabilities from scan data"""
        vulnerabilities = {
            "total": 0,
            "critical": 0,
            "high": 0,
            "medium": 0,
            "low": 0,
            "info": 0,
            "details": []
        }
        
        if tool == "bandit":
            for result in scan_data.get("results", []):
                severity = result.get("issue_severity", "unknown").lower()
                vulnerabilities["total"] += 1
                if severity in vulnerabilities:
                    vulnerabilities[severity] += 1
                
                vulnerabilities["details"].append({
                    "severity": severity,
                    "cwe_id": result.get("cwe_id"),
                    "test_name": result.get("test_name"),
                    "issue_text": result.get("issue_text"),
                    "file_path": result.get("filename"),
                    "line_number": result.get("line_number")
                })
        
        elif tool == "safety":
            for vuln in scan_data.get("vulnerabilities", []):
                severity = vuln.get("vulnerability_id", "unknown")
                vulnerabilities["total"] += 1
                if severity.startswith("CVE"):
                    vulnerabilities["high"] += 1
                else:
                    vulnerabilities["medium"] += 1
                
                vulnerabilities["details"].append({
                    "severity": "high",
                    "cve": vuln.get("vulnerability_id"),
                    "package": vuln.get("package"),
                    "version": vuln.get("installed_version"),
                    "advisory": vuln.get("advisory")
                })
        
        elif tool == "trivy":
            for result in scan_data.get("Results", []):
                for vuln in result.get("Vulnerabilities", []):
                    severity = vuln.get("Severity", "unknown").lower()
                    vulnerabilities["total"] += 1
                    if severity in vulnerabilities:
                        vulnerabilities[severity] += 1
                    
                    vulnerabilities["details"].append({
                        "severity": severity,
                        "cve": vuln.get("VulnerabilityID"),
                        "package": vuln.get("PkgName"),
                        "version": vuln.get("InstalledVersion"),
                        "title": vuln.get("Title"),
                        "description": vuln.get("Description")
                    })
        
        elif tool == "checkov":
            for result in scan_data.get("results", {}).get("failed_checks", []):
                severity = result.get("check_result", {}).get("result", "unknown").lower()
                vulnerabilities["total"] += 1
                if "failed" in severity:
                    vulnerabilities["medium"] += 1
                
                vulnerabilities["details"].append({
                    "severity": "medium",
                    "check_id": result.get("check_id"),
                    "check_name": result.get("check_name"),
                    "file_path": result.get("file_path"),
                    "resource": result.get("resource"),
                    "evaluation": result.get("check_result", {}).get("evaluation")
                })
        
        return vulnerabilities
    
    def run_compliance_checks(self) -> Dict[str, Any]:
        """Run compliance checks"""
        logger.info("Starting compliance checks...")
        compliance_results = {}
        
        for framework_config in self.config["compliance_frameworks"]:
            if not framework_config["enabled"]:
                continue
                
            logger.info(f"Running {framework_config['name']} compliance check...")
            
            try:
                result = self.check_compliance_framework(framework_config)
                compliance_results[framework_config["name"]] = result
                logger.info(f"{framework_config['name']} compliance check completed")
                
            except Exception as e:
                logger.error(f"Failed to run {framework_config['name']} compliance check: {e}")
                compliance_results[framework_config["name"]] = {
                    "status": "error",
                    "error": str(e),
                    "timestamp": datetime.now().isoformat()
                }
        
        self.results["compliance_checks"] = compliance_results
        return compliance_results
    
    def check_compliance_framework(self, framework_config: Dict[str, Any]) -> Dict[str, Any]:
        """Check compliance for a specific framework"""
        start_time = time.time()
        
        try:
            # Load compliance rules
            rules_file = f"compliance-rules/{framework_config['name'].lower()}.json"
            if Path(rules_file).exists():
                with open(rules_file, 'r') as f:
                    rules = json.load(f)
            else:
                rules = self.get_default_compliance_rules(framework_config["name"])
            
            # Run compliance checks
            check_results = []
            total_checks = 0
            passed_checks = 0
            
            for rule in rules["rules"]:
                total_checks += 1
                
                try:
                    check_result = self.run_compliance_rule(rule)
                    check_results.append(check_result)
                    
                    if check_result["status"] == "passed":
                        passed_checks += 1
                        
                except Exception as e:
                    logger.error(f"Failed to run compliance rule {rule['id']}: {e}")
                    check_results.append({
                        "rule_id": rule["id"],
                        "status": "error",
                        "error": str(e)
                    })
            
            # Calculate compliance score
            compliance_score = (passed_checks / total_checks) * 100 if total_checks > 0 else 0
            
            return {
                "status": "success",
                "framework": framework_config["name"],
                "description": framework_config["description"],
                "requirements": framework_config["requirements"],
                "controls": framework_config["controls"],
                "total_checks": total_checks,
                "passed_checks": passed_checks,
                "failed_checks": total_checks - passed_checks,
                "compliance_score": compliance_score,
                "check_results": check_results,
                "execution_time": time.time() - start_time,
                "timestamp": datetime.now().isoformat()
            }
            
        except Exception as e:
            return {
                "status": "error",
                "framework": framework_config["name"],
                "error": str(e),
                "execution_time": time.time() - start_time,
                "timestamp": datetime.now().isoformat()
            }
    
    def get_default_compliance_rules(self, framework: str) -> Dict[str, Any]:
        """Get default compliance rules for a framework"""
        if framework == "GDPR":
            return {
                "rules": [
                    {
                        "id": "gdpr_001",
                        "name": "Lawful basis for processing",
                        "description": "Ensure lawful basis exists for data processing",
                        "check_type": "configuration",
                        "check_command": "grep -r \"lawful_basis\" src/ || true",
                        "expected_result": "found",
                        "severity": "high"
                    },
                    {
                        "id": "gdpr_002",
                        "name": "Data encryption",
                        "description": "Ensure data is encrypted at rest and in transit",
                        "check_type": "configuration",
                        "check_command": "grep -r \"encrypt\" config/ || true",
                        "expected_result": "found",
                        "severity": "high"
                    }
                ]
            }
        elif framework == "SOC2":
            return {
                "rules": [
                    {
                        "id": "soc2_001",
                        "name": "Access control",
                        "description": "Ensure proper access controls are in place",
                        "check_type": "configuration",
                        "check_command": "grep -r \"access_control\" config/ || true",
                        "expected_result": "found",
                        "severity": "high"
                    }
                ]
            }
        elif framework == "ISO27001":
            return {
                "rules": [
                    {
                        "id": "iso27001_001",
                        "name": "Security policy",
                        "description": "Ensure security policy exists and is documented",
                        "check_type": "documentation",
                        "check_command": "ls docs/security-policy.md || true",
                        "expected_result": "exists",
                        "severity": "medium"
                    }
                ]
            }
        else:
            return {"rules": []}
    
    def run_compliance_rule(self, rule: Dict[str, Any]) -> Dict[str, Any]:
        """Run a single compliance rule"""
        try:
            result = subprocess.run(
                rule["check_command"],
                shell=True,
                capture_output=True,
                text=True,
                timeout=60
            )
            
            if rule["check_type"] == "configuration":
                passed = rule["expected_result"] in result.stdout.lower()
            elif rule["check_type"] == "documentation":
                passed = result.returncode == 0
            else:
                passed = False
            
            return {
                "rule_id": rule["id"],
                "rule_name": rule["name"],
                "description": rule["description"],
                "check_type": rule["check_type"],
                "command": rule["check_command"],
                "expected_result": rule["expected_result"],
                "actual_result": result.stdout.strip(),
                "status": "passed" if passed else "failed",
                "severity": rule["severity"],
                "timestamp": datetime.now().isoformat()
            }
            
        except subprocess.TimeoutExpired:
            return {
                "rule_id": rule["id"],
                "rule_name": rule["name"],
                "status": "timeout",
                "error": "Check timed out",
                "timestamp": datetime.now().isoformat()
            }
    
    def generate_reports(self) -> Dict[str, Any]:
        """Generate security and compliance reports"""
        logger.info("Generating security and compliance reports...")
        
        try:
            # Create output directory
            output_dir = Path(self.config["reporting"]["output_dir"])
            output_dir.mkdir(exist_ok=True)
            
            # Generate executive report
            executive_report = self.generate_executive_report(output_dir)
            
            # Generate technical report
            technical_report = self.generate_technical_report(output_dir)
            
            # Generate compliance report
            compliance_report = self.generate_compliance_report(output_dir)
            
            # Generate PDF reports if enabled
            if self.config["reporting"]["pdf_output"]:
                self.generate_pdf_reports(output_dir)
            
            reports = {
                "executive_report": executive_report,
                "technical_report": technical_report,
                "compliance_report": compliance_report,
                "output_dir": str(output_dir),
                "timestamp": datetime.now().isoformat()
            }
            
            self.results["reports"] = reports
            return reports
            
        except Exception as e:
            logger.error(f"Failed to generate reports: {e}")
            return {
                "status": "error",
                "error": str(e),
                "timestamp": datetime.now().isoformat()
            }
    
    def generate_executive_report(self, output_dir: Path) -> str:
        """Generate executive security report"""
        template_file = self.config["reporting"]["executive_template"]
        output_file = output_dir / "executive-security-report.html"
        
        try:
            # Prepare template data
            template_data = {
                "report_title": "Executive Security Report",
                "generated_at": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                "environment": self.environment,
                "security_scans": self.results.get("security_scans", {}),
                "compliance_checks": self.results.get("compliance_checks", {}),
                "summary": self.calculate_executive_summary()
            }
            
            # Render template
            env = jinja2.Environment(loader=jinja2.FileSystemLoader('.'))
            template = env.get_template(template_file)
            rendered = template.render(**template_data)
            
            # Save report
            with open(output_file, 'w') as f:
                f.write(rendered)
            
            logger.info(f"Executive report generated: {output_file}")
            return str(output_file)
            
        except Exception as e:
            logger.error(f"Failed to generate executive report: {e}")
            raise
    
    def generate_technical_report(self, output_dir: Path) -> str:
        """Generate technical security report"""
        template_file = self.config["reporting"]["technical_template"]
        output_file = output_dir / "technical-security-report.html"
        
        try:
            # Prepare template data
            template_data = {
                "report_title": "Technical Security Report",
                "generated_at": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                "environment": self.environment,
                "security_scans": self.results.get("security_scans", {}),
                "compliance_checks": self.results.get("compliance_checks", {}),
                "details": self.calculate_technical_details()
            }
            
            # Render template
            env = jinja2.Environment(loader=jinja2.FileSystemLoader('.'))
            template = env.get_template(template_file)
            rendered = template.render(**template_data)
            
            # Save report
            with open(output_file, 'w') as f:
                f.write(rendered)
            
            logger.info(f"Technical report generated: {output_file}")
            return str(output_file)
            
        except Exception as e:
            logger.error(f"Failed to generate technical report: {e}")
            raise
    
    def generate_compliance_report(self, output_dir: Path) -> str:
        """Generate compliance report"""
        template_file = self.config["reporting"]["compliance_template"]
        output_file = output_dir / "compliance-report.html"
        
        try:
            # Prepare template data
            template_data = {
                "report_title": "Compliance Report",
                "generated_at": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                "environment": self.environment,
                "compliance_checks": self.results.get("compliance_checks", {}),
                "summary": self.calculate_compliance_summary()
            }
            
            # Render template
            env = jinja2.Environment(loader=jinja2.FileSystemLoader('.'))
            template = env.get_template(template_file)
            rendered = template.render(**template_data)
            
            # Save report
            with open(output_file, 'w') as f:
                f.write(rendered)
            
            logger.info(f"Compliance report generated: {output_file}")
            return str(output_file)
            
        except Exception as e:
            logger.error(f"Failed to generate compliance report: {e}")
            raise
    
    def calculate_executive_summary(self) -> Dict[str, Any]:
        """Calculate executive summary metrics"""
        security_scans = self.results.get("security_scans", {})
        compliance_checks = self.results.get("compliance_checks", {})
        
        total_vulnerabilities = 0
        critical_vulnerabilities = 0
        high_vulnerabilities = 0
        
        for scan_name, scan_result in security_scans.items():
            if scan_result.get("status") == "success":
                vulns = scan_result.get("vulnerabilities", {})
                total_vulnerabilities += vulns.get("total", 0)
                critical_vulnerabilities += vulns.get("critical", 0)
                high_vulnerabilities += vulns.get("high", 0)
        
        total_compliance_checks = 0
        passed_compliance_checks = 0
        overall_compliance_score = 0
        
        for framework_name, framework_result in compliance_checks.items():
            if framework_result.get("status") == "success":
                total_compliance_checks += framework_result.get("total_checks", 0)
                passed_compliance_checks += framework_result.get("passed_checks", 0)
                overall_compliance_score += framework_result.get("compliance_score", 0)
        
        avg_compliance_score = overall_compliance_score / len(compliance_checks) if compliance_checks else 0
        
        return {
            "total_vulnerabilities": total_vulnerabilities,
            "critical_vulnerabilities": critical_vulnerabilities,
            "high_vulnerabilities": high_vulnerabilities,
            "total_compliance_checks": total_compliance_checks,
            "passed_compliance_checks": passed_compliance_checks,
            "failed_compliance_checks": total_compliance_checks - passed_compliance_checks,
            "average_compliance_score": avg_compliance_score,
            "security_status": "healthy" if critical_vulnerabilities == 0 else "at_risk",
            "compliance_status": "compliant" if avg_compliance_score >= 95 else "non_compliant"
        }
    
    def calculate_technical_details(self) -> Dict[str, Any]:
        """Calculate technical details"""
        security_scans = self.results.get("security_scans", {})
        
        scan_details = {}
        for scan_name, scan_result in security_scans.items():
            if scan_result.get("status") == "success":
                scan_details[scan_name] = {
                    "tool": scan_result.get("tool"),
                    "execution_time": scan_result.get("execution_time"),
                    "vulnerabilities": scan_result.get("vulnerabilities"),
                    "severity_threshold": scan_result.get("severity_threshold")
                }
        
        return {
            "scan_details": scan_details,
            "vulnerability_trends": self.calculate_vulnerability_trends(),
            "compliance_details": self.results.get("compliance_checks", {})
        }
    
    def calculate_compliance_summary(self) -> Dict[str, Any]:
        """Calculate compliance summary"""
        compliance_checks = self.results.get("compliance_checks", {})
        
        framework_summary = {}
        for framework_name, framework_result in compliance_checks.items():
            if framework_result.get("status") == "success":
                framework_summary[framework_name] = {
                    "compliance_score": framework_result.get("compliance_score"),
                    "total_checks": framework_result.get("total_checks"),
                    "passed_checks": framework_result.get("passed_checks"),
                    "failed_checks": framework_result.get("failed_checks"),
                    "status": "compliant" if framework_result.get("compliance_score") >= 95 else "non_compliant"
                }
        
        return framework_summary
    
    def calculate_vulnerability_trends(self) -> Dict[str, Any]:
        """Calculate vulnerability trends (placeholder for historical data)"""
        return {
            "trend": "stable",
            "trend_data": []
        }
    
    def generate_pdf_reports(self, output_dir: Path):
        """Generate PDF versions of reports"""
        pdf_dir = output_dir / "pdf"
        pdf_dir.mkdir(exist_ok=True)
        
        try:
            # Convert HTML to PDF
            html_files = [
                "executive-security-report.html",
                "technical-security-report.html",
                "compliance-report.html"
            ]
            
            for html_file in html_files:
                html_path = output_dir / html_file
                pdf_path = pdf_dir / html_file.replace(".html", ".pdf")
                
                if html_path.exists():
                    # Convert HTML to PDF using WeasyPrint
                    html_doc = weasyprint.HTML(filename=str(html_path))
                    html_doc.write_pdf(str(pdf_path))
                    logger.info(f"PDF report generated: {pdf_path}")
        
        except Exception as e:
            logger.error(f"Failed to generate PDF reports: {e}")
    
    def send_notifications(self):
        """Send security and compliance notifications"""
        logger.info("Sending notifications...")
        
        try:
            # Send Slack notification
            if self.config["notifications"]["slack_webhook"]:
                self.send_slack_notification()
            
            # Send email notification
            if self.config["notifications"]["email_enabled"]:
                self.send_email_notification()
                
        except Exception as e:
            logger.error(f"Failed to send notifications: {e}")
    
    def send_slack_notification(self):
        """Send Slack notification"""
        try:
            webhook_url = self.config["notifications"]["slack_webhook"]
            summary = self.calculate_executive_summary()
            
            # Create Slack message
            color = "good" if summary["security_status"] == "healthy" else "warning"
            if summary["critical_vulnerabilities"] > 0:
                color = "danger"
            
            message = {
                "text": f"Security and Compliance Report - {self.environment.upper()}",
                "attachments": [
                    {
                        "color": color,
                        "fields": [
                            {
                                "title": "Security Status",
                                "value": summary["security_status"].upper(),
                                "short": True
                            },
                            {
                                "title": "Compliance Status",
                                "value": summary["compliance_status"].upper(),
                                "short": True
                            },
                            {
                                "title": "Total Vulnerabilities",
                                "value": str(summary["total_vulnerabilities"]),
                                "short": True
                            },
                            {
                                "title": "Critical Vulnerabilities",
                                "value": str(summary["critical_vulnerabilities"]),
                                "short": True
                            },
                            {
                                "title": "Compliance Score",
                                "value": f"{summary['average_compliance_score']:.1f}%",
                                "short": True
                            },
                            {
                                "title": "Generated At",
                                "value": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                                "short": True
                            }
                        ]
                    }
                ]
            }
            
            response = requests.post(webhook_url, json=message, timeout=10)
            response.raise_for_status()
            logger.info("Slack notification sent successfully")
            
        except Exception as e:
            logger.error(f"Failed to send Slack notification: {e}")
    
    def send_email_notification(self):
        """Send email notification"""
        try:
            import smtplib
            from email.mime.text import MIMEText
            from email.mime.multipart import MIMEMultipart
            
            smtp_config = self.config["notifications"]
            summary = self.calculate_executive_summary()
            
            # Create message
            msg = MIMEMultipart()
            msg['From'] = smtp_config["smtp_username"]
            msg['To'] = ", ".join(smtp_config["email_recipients"])
            msg['Subject'] = f"Security and Compliance Report - {self.environment.upper()}"
            
            # Create body
            body = f"""
Security and Compliance Report for {self.environment.upper()}

Generated: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}

Executive Summary:
- Security Status: {summary['security_status'].upper()}
- Compliance Status: {summary['compliance_status'].upper()}
- Total Vulnerabilities: {summary['total_vulnerabilities']}
- Critical Vulnerabilities: {summary['critical_vulnerabilities']}
- High Vulnerabilities: {summary['high_vulnerabilities']}
- Average Compliance Score: {summary['average_compliance_score']:.1f}%

Compliance Details:
- Total Compliance Checks: {summary['total_compliance_checks']}
- Passed Compliance Checks: {summary['passed_compliance_checks']}
- Failed Compliance Checks: {summary['failed_compliance_checks']}

Detailed reports are available in the reports directory.

This is an automated message from the Security and Compliance Automation System.
            """
            
            msg.attach(MIMEText(body, 'plain'))
            
            # Send email
            with smtplib.SMTP(smtp_config["smtp_server"], smtp_config["smtp_port"]) as server:
                server.starttls()
                server.login(smtp_config["smtp_username"], smtp_config["smtp_password"])
                server.send_message(msg)
            
            logger.info("Email notification sent successfully")
            
        except Exception as e:
            logger.error(f"Failed to send email notification: {e}")
    
    def run_complete_automation(self) -> Dict[str, Any]:
        """Run complete security and compliance automation"""
        logger.info("Starting complete security and compliance automation...")
        
        try:
            # Run security scans
            security_results = self.run_security_scans()
            
            # Run compliance checks
            compliance_results = self.run_compliance_checks()
            
            # Generate reports
            report_results = self.generate_reports()
            
            # Send notifications
            self.send_notifications()
            
            # Compile final results
            final_results = {
                "status": "success",
                "environment": self.environment,
                "timestamp": datetime.now().isoformat(),
                "security_scans": security_results,
                "compliance_checks": compliance_results,
                "reports": report_results,
                "summary": self.calculate_executive_summary()
            }
            
            logger.info("Security and compliance automation completed successfully")
            return final_results
            
        except Exception as e:
            logger.error(f"Security and compliance automation failed: {e}")
            return {
                "status": "error",
                "error": str(e),
                "timestamp": datetime.now().isoformat()
            }

def main():
    """Main function"""
    parser = argparse.ArgumentParser(description="Security and Compliance Automation")
    parser.add_argument("--environment", default="production", help="Environment name")
    parser.add_argument("--config", help="Configuration file path")
    parser.add_argument("--security-only", action="store_true", help="Run security scans only")
    parser.add_argument("--compliance-only", action="store_true", help="Run compliance checks only")
    parser.add_argument("--reports-only", action="store_true", help="Generate reports only")
    parser.add_argument("--notify-only", action="store_true", help="Send notifications only")
    parser.add_argument("--verbose", action="store_true", help="Enable verbose logging")
    
    args = parser.parse_args()
    
    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)
    
    # Create automation system
    automation = SecurityComplianceAutomation(args.config, args.environment)
    
    try:
        if args.security_only:
            results = automation.run_security_scans()
        elif args.compliance_only:
            results = automation.run_compliance_checks()
        elif args.reports_only:
            results = automation.generate_reports()
        elif args.notify_only:
            automation.send_notifications()
            results = {"status": "notifications_sent"}
        else:
            results = automation.run_complete_automation()
        
        # Save results
        results_file = f"security-compliance-results-{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(results_file, 'w') as f:
            json.dump(results, f, indent=2)
        
        # Print summary
        if "summary" in results:
            summary = results["summary"]
            print(f"\nSecurity and Compliance Summary:")
            print(f"Environment: {args.environment}")
            print(f"Security Status: {summary['security_status'].upper()}")
            print(f"Compliance Status: {summary['compliance_status'].upper()}")
            print(f"Total Vulnerabilities: {summary['total_vulnerabilities']}")
            print(f"Critical Vulnerabilities: {summary['critical_vulnerabilities']}")
            print(f"Average Compliance Score: {summary['average_compliance_score']:.1f}%")
        
        print(f"\nResults saved to: {results_file}")
        
        # Exit with appropriate code
        if results.get("status") == "success":
            if summary.get("critical_vulnerabilities", 0) > 0:
                sys.exit(1)  # Critical vulnerabilities found
            elif summary.get("compliance_status") == "non_compliant":
                sys.exit(2)  # Non-compliant
            else:
                sys.exit(0)  # Success
        else:
            sys.exit(3)  # Error
    
    except Exception as e:
        logger.error(f"Automation failed: {e}")
        sys.exit(3)

if __name__ == "__main__":
    main()
