#!/usr/bin/env python3
"""
DevOps Backup Automation Script
Comprehensive backup automation for databases, applications, and configurations
"""

import os
import sys
import json
import time
import logging
import argparse
import subprocess
import hashlib
import shutil
import gzip
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any
from pathlib import Path
import boto3
import botocore
from google.cloud import storage
from azure.storage.blob import BlobServiceClient
import psycopg2
import redis

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('devops-backup.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class BackupConfig:
    """Backup configuration"""
    
    def __init__(self, config_file: str = None):
        self.config_file = config_file or "backup-config.json"
        self.config = self.load_config()
    
    def load_config(self) -> Dict[str, Any]:
        """Load backup configuration"""
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
        """Get default backup configuration"""
        return {
            "backup_dir": "/opt/backups",
            "retention_days": 30,
            "compression": True,
            "encryption": False,
            "storage": {
                "provider": "local",
                "credentials": {}
            },
            "databases": [
                {
                    "type": "postgresql",
                    "name": "spaceinvaders",
                    "host": "localhost",
                    "port": 5432,
                    "username": "spaceinvaders",
                    "password": "password",
                    "database": "spaceinvaders"
                }
            ],
            "applications": [
                {
                    "name": "space-invaders",
                    "paths": [
                        "/opt/space-invaders",
                        "/etc/space-invaders"
                    ],
                    "exclude": [
                        "*.tmp",
                        "*.log",
                        "cache/*"
                    ]
                }
            ],
            "notifications": {
                "slack": {
                    "enabled": False,
                    "webhook": ""
                },
                "email": {
                    "enabled": False,
                    "smtp_server": "",
                    "from": "",
                    "to": []
                }
            }
        }

class BackupManager:
    """Backup Manager"""
    
    def __init__(self, config: BackupConfig, environment: str = "production"):
        self.config = config.config
        self.environment = environment
        self.backup_dir = Path(self.config["backup_dir"]) / environment
        self.backup_dir.mkdir(parents=True, exist_ok=True)
        self.timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
    def create_backup(self) -> Dict[str, Any]:
        """Create comprehensive backup"""
        logger.info(f"Starting backup for environment: {self.environment}")
        
        backup_results = {
            "timestamp": self.timestamp,
            "environment": self.environment,
            "databases": {},
            "applications": {},
            "configurations": {},
            "storage": {},
            "summary": {
                "total_size": 0,
                "success_count": 0,
                "error_count": 0,
                "duration": 0
            }
        }
        
        start_time = time.time()
        
        try:
            # Backup databases
            backup_results["databases"] = self.backup_databases()
            
            # Backup applications
            backup_results["applications"] = self.backup_applications()
            
            # Backup configurations
            backup_results["configurations"] = self.backup_configurations()
            
            # Upload to storage
            backup_results["storage"] = self.upload_to_storage()
            
            # Calculate summary
            backup_results["summary"] = self.calculate_summary(backup_results, start_time)
            
            # Send notifications
            self.send_notifications(backup_results)
            
            logger.info(f"Backup completed successfully")
            return backup_results
            
        except Exception as e:
            logger.error(f"Backup failed: {e}")
            backup_results["summary"]["error"] = str(e)
            self.send_notifications(backup_results)
            raise
    
    def backup_databases(self) -> Dict[str, Any]:
        """Backup databases"""
        results = {}
        
        for db_config in self.config["databases"]:
            db_name = db_config["name"]
            logger.info(f"Backing up database: {db_name}")
            
            try:
                if db_config["type"] == "postgresql":
                    result = self.backup_postgresql(db_config)
                elif db_config["type"] == "mysql":
                    result = self.backup_mysql(db_config)
                elif db_config["type"] == "redis":
                    result = self.backup_redis(db_config)
                else:
                    raise ValueError(f"Unsupported database type: {db_config['type']}")
                
                results[db_name] = result
                logger.info(f"Database {db_name} backed up successfully")
                
            except Exception as e:
                logger.error(f"Failed to backup database {db_name}: {e}")
                results[db_name] = {
                    "status": "error",
                    "error": str(e),
                    "timestamp": datetime.now().isoformat()
                }
        
        return results
    
    def backup_postgresql(self, config: Dict[str, Any]) -> Dict[str, Any]:
        """Backup PostgreSQL database"""
        backup_file = self.backup_dir / f"postgresql_{config['name']}_{self.timestamp}.sql"
        
        try:
            # Create backup using pg_dump
            cmd = [
                "pg_dump",
                "-h", config["host"],
                "-p", str(config["port"]),
                "-U", config["username"],
                "-d", config["database"],
                "-f", str(backup_file),
                "--verbose",
                "--no-password",
                "--format=custom",
                "--compress=9"
            ]
            
            # Set password in environment
            env = os.environ.copy()
            env["PGPASSWORD"] = config["password"]
            
            result = subprocess.run(cmd, env=env, capture_output=True, text=True, timeout=3600)
            
            if result.returncode != 0:
                raise subprocess.CalledProcessError(result.returncode, cmd, result.stdout, result.stderr)
            
            # Compress if enabled
            if self.config["compression"]:
                backup_file = self.compress_file(backup_file)
            
            # Calculate checksum
            checksum = self.calculate_checksum(backup_file)
            
            return {
                "status": "success",
                "file": str(backup_file),
                "size": backup_file.stat().st_size,
                "checksum": checksum,
                "timestamp": datetime.now().isoformat()
            }
            
        except Exception as e:
            # Clean up on error
            if backup_file.exists():
                backup_file.unlink()
            raise
    
    def backup_mysql(self, config: Dict[str, Any]) -> Dict[str, Any]:
        """Backup MySQL database"""
        backup_file = self.backup_dir / f"mysql_{config['name']}_{self.timestamp}.sql"
        
        try:
            # Create backup using mysqldump
            cmd = [
                "mysqldump",
                "-h", config["host"],
                "-P", str(config["port"]),
                "-u", config["username"],
                f"-p{config['password']}",
                "--single-transaction",
                "--routines",
                "--triggers",
                "--all-databases" if config.get("all_databases", False) else config["database"],
                "--result-file", str(backup_file)
            ]
            
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=3600)
            
            if result.returncode != 0:
                raise subprocess.CalledProcessError(result.returncode, cmd, result.stdout, result.stderr)
            
            # Compress if enabled
            if self.config["compression"]:
                backup_file = self.compress_file(backup_file)
            
            # Calculate checksum
            checksum = self.calculate_checksum(backup_file)
            
            return {
                "status": "success",
                "file": str(backup_file),
                "size": backup_file.stat().st_size,
                "checksum": checksum,
                "timestamp": datetime.now().isoformat()
            }
            
        except Exception as e:
            # Clean up on error
            if backup_file.exists():
                backup_file.unlink()
            raise
    
    def backup_redis(self, config: Dict[str, Any]) -> Dict[str, Any]:
        """Backup Redis database"""
        backup_file = self.backup_dir / f"redis_{config['name']}_{self.timestamp}.rdb"
        
        try:
            # Connect to Redis
            r = redis.Redis(
                host=config.get("host", "localhost"),
                port=config.get("port", 6379),
                password=config.get("password"),
                db=config.get("db", 0)
            )
            
            # Save Redis data
            r.save()
            
            # Wait for save to complete
            time.sleep(2)
            
            # Copy Redis dump file
            redis_dump = Path("/var/lib/redis/dump.rdb")
            if not redis_dump.exists():
                redis_dump = Path(f"/var/lib/redis/{config.get('db', 0)}/dump.rdb")
            
            if not redis_dump.exists():
                raise FileNotFoundError("Redis dump file not found")
            
            shutil.copy2(redis_dump, backup_file)
            
            # Compress if enabled
            if self.config["compression"]:
                backup_file = self.compress_file(backup_file)
            
            # Calculate checksum
            checksum = self.calculate_checksum(backup_file)
            
            return {
                "status": "success",
                "file": str(backup_file),
                "size": backup_file.stat().st_size,
                "checksum": checksum,
                "timestamp": datetime.now().isoformat()
            }
            
        except Exception as e:
            # Clean up on error
            if backup_file.exists():
                backup_file.unlink()
            raise
    
    def backup_applications(self) -> Dict[str, Any]:
        """Backup applications"""
        results = {}
        
        for app_config in self.config["applications"]:
            app_name = app_config["name"]
            logger.info(f"Backing up application: {app_name}")
            
            try:
                result = self.backup_application(app_config)
                results[app_name] = result
                logger.info(f"Application {app_name} backed up successfully")
                
            except Exception as e:
                logger.error(f"Failed to backup application {app_name}: {e}")
                results[app_name] = {
                    "status": "error",
                    "error": str(e),
                    "timestamp": datetime.now().isoformat()
                }
        
        return results
    
    def backup_application(self, config: Dict[str, Any]) -> Dict[str, Any]:
        """Backup single application"""
        backup_file = self.backup_dir / f"app_{config['name']}_{self.timestamp}.tar"
        
        try:
            # Create tar archive
            cmd = ["tar", "-cf", str(backup_file)]
            
            # Add paths
            for path in config["paths"]:
                if Path(path).exists():
                    cmd.append(path)
                else:
                    logger.warning(f"Path does not exist: {path}")
            
            # Add exclude patterns
            for exclude in config.get("exclude", []):
                cmd.extend(["--exclude", exclude])
            
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=3600)
            
            if result.returncode != 0:
                raise subprocess.CalledProcessError(result.returncode, cmd, result.stdout, result.stderr)
            
            # Compress if enabled
            if self.config["compression"]:
                backup_file = self.compress_file(backup_file)
            
            # Calculate checksum
            checksum = self.calculate_checksum(backup_file)
            
            return {
                "status": "success",
                "file": str(backup_file),
                "size": backup_file.stat().st_size,
                "checksum": checksum,
                "timestamp": datetime.now().isoformat()
            }
            
        except Exception as e:
            # Clean up on error
            if backup_file.exists():
                backup_file.unlink()
            raise
    
    def backup_configurations(self) -> Dict[str, Any]:
        """Backup system configurations"""
        results = {}
        
        config_paths = [
            "/etc/nginx",
            "/etc/ssh",
            "/etc/systemd/system",
            "/etc/hosts",
            "/etc/fstab",
            "/etc/crontab",
            "/var/spool/cron"
        ]
        
        backup_file = self.backup_dir / f"configurations_{self.timestamp}.tar"
        
        try:
            # Create tar archive
            cmd = ["tar", "-cf", str(backup_file)]
            
            # Add existing paths
            for path in config_paths:
                if Path(path).exists():
                    cmd.append(path)
            
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=1800)
            
            if result.returncode != 0:
                raise subprocess.CalledProcessError(result.returncode, cmd, result.stdout, result.stderr)
            
            # Compress if enabled
            if self.config["compression"]:
                backup_file = self.compress_file(backup_file)
            
            # Calculate checksum
            checksum = self.calculate_checksum(backup_file)
            
            results["system"] = {
                "status": "success",
                "file": str(backup_file),
                "size": backup_file.stat().st_size,
                "checksum": checksum,
                "timestamp": datetime.now().isoformat()
            }
            
        except Exception as e:
            # Clean up on error
            if backup_file.exists():
                backup_file.unlink()
            results["system"] = {
                "status": "error",
                "error": str(e),
                "timestamp": datetime.now().isoformat()
            }
        
        return results
    
    def compress_file(self, file_path: Path) -> Path:
        """Compress file using gzip"""
        compressed_path = file_path.with_suffix(file_path.suffix + ".gz")
        
        try:
            with open(file_path, 'rb') as f_in:
                with gzip.open(compressed_path, 'wb') as f_out:
                    shutil.copyfileobj(f_in, f_out)
            
            # Remove original file
            file_path.unlink()
            
            return compressed_path
            
        except Exception as e:
            # Clean up on error
            if compressed_path.exists():
                compressed_path.unlink()
            raise
    
    def calculate_checksum(self, file_path: Path) -> str:
        """Calculate SHA256 checksum"""
        hash_sha256 = hashlib.sha256()
        
        with open(file_path, "rb") as f:
            for chunk in iter(lambda: f.read(4096), b""):
                hash_sha256.update(chunk)
        
        return hash_sha256.hexdigest()
    
    def upload_to_storage(self) -> Dict[str, Any]:
        """Upload backups to storage"""
        storage_config = self.config["storage"]
        provider = storage_config["provider"]
        
        try:
            if provider == "s3":
                return self.upload_to_s3(storage_config)
            elif provider == "gcs":
                return self.upload_to_gcs(storage_config)
            elif provider == "azure":
                return self.upload_to_azure(storage_config)
            elif provider == "local":
                return {"status": "success", "provider": "local"}
            else:
                raise ValueError(f"Unsupported storage provider: {provider}")
                
        except Exception as e:
            logger.error(f"Failed to upload to storage: {e}")
            return {
                "status": "error",
                "error": str(e),
                "timestamp": datetime.now().isoformat()
            }
    
    def upload_to_s3(self, config: Dict[str, Any]) -> Dict[str, Any]:
        """Upload backups to AWS S3"""
        try:
            s3_client = boto3.client(
                's3',
                aws_access_key_id=config["credentials"]["access_key_id"],
                aws_secret_access_key=config["credentials"]["secret_access_key"],
                region_name=config["credentials"].get("region", "us-east-1")
            )
            
            bucket_name = config["bucket"]
            prefix = f"backups/{self.environment}/{self.timestamp}/"
            
            uploaded_files = []
            
            # Upload all backup files
            for backup_file in self.backup_dir.glob("*"):
                if backup_file.is_file():
                    s3_key = prefix + backup_file.name
                    
                    s3_client.upload_file(
                        str(backup_file),
                        bucket_name,
                        s3_key,
                        ExtraArgs={
                            'ServerSideEncryption': 'AES256'
                        }
                    )
                    
                    uploaded_files.append({
                        "local_file": str(backup_file),
                        "s3_key": s3_key,
                        "size": backup_file.stat().st_size
                    })
            
            return {
                "status": "success",
                "provider": "s3",
                "bucket": bucket_name,
                "prefix": prefix,
                "uploaded_files": uploaded_files,
                "timestamp": datetime.now().isoformat()
            }
            
        except Exception as e:
            raise
    
    def upload_to_gcs(self, config: Dict[str, Any]) -> Dict[str, Any]:
        """Upload backups to Google Cloud Storage"""
        try:
            client = storage.Client.from_service_account_json(
                config["credentials"]["service_account_key"]
            )
            
            bucket_name = config["bucket"]
            bucket = client.bucket(bucket_name)
            prefix = f"backups/{self.environment}/{self.timestamp}/"
            
            uploaded_files = []
            
            # Upload all backup files
            for backup_file in self.backup_dir.glob("*"):
                if backup_file.is_file():
                    blob_name = prefix + backup_file.name
                    blob = bucket.blob(blob_name)
                    
                    blob.upload_from_filename(str(backup_file))
                    
                    uploaded_files.append({
                        "local_file": str(backup_file),
                        "blob_name": blob_name,
                        "size": backup_file.stat().st_size
                    })
            
            return {
                "status": "success",
                "provider": "gcs",
                "bucket": bucket_name,
                "prefix": prefix,
                "uploaded_files": uploaded_files,
                "timestamp": datetime.now().isoformat()
            }
            
        except Exception as e:
            raise
    
    def upload_to_azure(self, config: Dict[str, Any]) -> Dict[str, Any]:
        """Upload backups to Azure Blob Storage"""
        try:
            blob_service_client = BlobServiceClient(
                account_url=config["credentials"]["account_url"],
                credential=config["credentials"]["credential"]
            )
            
            container_name = config["container"]
            prefix = f"backups/{self.environment}/{self.timestamp}/"
            
            uploaded_files = []
            
            # Upload all backup files
            for backup_file in self.backup_dir.glob("*"):
                if backup_file.is_file():
                    blob_name = prefix + backup_file.name
                    
                    with open(backup_file, "rb") as data:
                        blob_service_client.upload_blob(
                            container_name=container_name,
                            name=blob_name,
                            data=data
                        )
                    
                    uploaded_files.append({
                        "local_file": str(backup_file),
                        "blob_name": blob_name,
                        "size": backup_file.stat().st_size
                    })
            
            return {
                "status": "success",
                "provider": "azure",
                "container": container_name,
                "prefix": prefix,
                "uploaded_files": uploaded_files,
                "timestamp": datetime.now().isoformat()
            }
            
        except Exception as e:
            raise
    
    def calculate_summary(self, backup_results: Dict[str, Any], start_time: float) -> Dict[str, Any]:
        """Calculate backup summary"""
        total_size = 0
        success_count = 0
        error_count = 0
        
        # Calculate totals
        for category in ["databases", "applications", "configurations"]:
            for item in backup_results[category].values():
                if item.get("status") == "success":
                    success_count += 1
                    total_size += item.get("size", 0)
                else:
                    error_count += 1
        
        return {
            "total_size": total_size,
            "success_count": success_count,
            "error_count": error_count,
            "duration": time.time() - start_time,
            "timestamp": datetime.now().isoformat()
        }
    
    def send_notifications(self, backup_results: Dict[str, Any]):
        """Send backup notifications"""
        try:
            # Send Slack notification
            if self.config["notifications"]["slack"]["enabled"]:
                self.send_slack_notification(backup_results)
            
            # Send email notification
            if self.config["notifications"]["email"]["enabled"]:
                self.send_email_notification(backup_results)
                
        except Exception as e:
            logger.error(f"Failed to send notifications: {e}")
    
    def send_slack_notification(self, backup_results: Dict[str, Any]):
        """Send Slack notification"""
        try:
            import requests
            
            webhook_url = self.config["notifications"]["slack"]["webhook"]
            
            # Determine status and color
            summary = backup_results["summary"]
            if summary["error_count"] == 0:
                status = "✅ Success"
                color = "good"
            else:
                status = "❌ Failed"
                color = "danger"
            
            # Create message
            message = {
                "text": f"Backup {status} - {self.environment.upper()}",
                "attachments": [
                    {
                        "color": color,
                        "fields": [
                            {
                                "title": "Environment",
                                "value": self.environment.upper(),
                                "short": True
                            },
                            {
                                "title": "Duration",
                                "value": f"{summary['duration']:.2f}s",
                                "short": True
                            },
                            {
                                "title": "Total Size",
                                "value": f"{summary['total_size'] / 1024 / 1024:.2f} MB",
                                "short": True
                            },
                            {
                                "title": "Success/Error",
                                "value": f"{summary['success_count']}/{summary['error_count']}",
                                "short": True
                            },
                            {
                                "title": "Timestamp",
                                "value": backup_results["timestamp"],
                                "short": False
                            }
                        ]
                    }
                ]
            }
            
            # Add errors if any
            if summary["error_count"] > 0:
                errors = []
                for category in ["databases", "applications", "configurations"]:
                    for name, result in backup_results[category].items():
                        if result.get("status") == "error":
                            errors.append(f"• {category.title()} {name}: {result.get('error', 'Unknown error')}")
                
                if errors:
                    message["attachments"][0]["fields"].append({
                        "title": "Errors",
                        "value": "\n".join(errors[:10]),  # Limit to 10 errors
                        "short": False
                    })
            
            response = requests.post(webhook_url, json=message, timeout=10)
            response.raise_for_status()
            
        except Exception as e:
            logger.error(f"Failed to send Slack notification: {e}")
    
    def send_email_notification(self, backup_results: Dict[str, Any]):
        """Send email notification"""
        try:
            import smtplib
            from email.mime.text import MIMEText
            from email.mime.multipart import MIMEMultipart
            
            email_config = self.config["notifications"]["email"]
            
            # Create message
            msg = MIMEMultipart()
            msg['From'] = email_config["from"]
            msg['To'] = ", ".join(email_config["to"])
            msg['Subject'] = f"Backup Report - {self.environment.upper()}"
            
            # Create body
            summary = backup_results["summary"]
            
            body = f"""
Backup Report for {self.environment.upper()}

Timestamp: {backup_results['timestamp']}
Duration: {summary['duration']:.2f} seconds
Total Size: {summary['total_size'] / 1024 / 1024:.2f} MB
Success: {summary['success_count']}
Errors: {summary['error_count']}

"""
            
            # Add details
            for category in ["databases", "applications", "configurations"]:
                body += f"\n{category.title()}:\n"
                for name, result in backup_results[category].items():
                    status = result.get("status", "unknown")
                    if status == "success":
                        body += f"  ✅ {name}: {result.get('size', 0) / 1024 / 1024:.2f} MB\n"
                    else:
                        body += f"  ❌ {name}: {result.get('error', 'Unknown error')}\n"
            
            msg.attach(MIMEText(body, 'plain'))
            
            # Send email
            with smtplib.SMTP(email_config["smtp_server"], 587) as server:
                server.starttls()
                server.login(email_config["username"], email_config["password"])
                server.send_message(msg)
            
        except Exception as e:
            logger.error(f"Failed to send email notification: {e}")
    
    def cleanup_old_backups(self):
        """Clean up old backups"""
        try:
            retention_days = self.config["retention_days"]
            cutoff_date = datetime.now() - timedelta(days=retention_days)
            
            deleted_count = 0
            deleted_size = 0
            
            # Clean up local backups
            for backup_file in self.backup_dir.glob("*"):
                if backup_file.is_file():
                    file_time = datetime.fromtimestamp(backup_file.stat().st_mtime)
                    if file_time < cutoff_date:
                        file_size = backup_file.stat().st_size
                        backup_file.unlink()
                        deleted_count += 1
                        deleted_size += file_size
            
            logger.info(f"Cleaned up {deleted_count} old backup files ({deleted_size / 1024 / 1024:.2f} MB)")
            
            # Clean up storage backups (if implemented)
            # This would require additional implementation per storage provider
            
        except Exception as e:
            logger.error(f"Failed to cleanup old backups: {e}")

def main():
    """Main function"""
    parser = argparse.ArgumentParser(description="DevOps Backup Automation")
    parser.add_argument("--environment", default="production", help="Environment name")
    parser.add_argument("--config", help="Configuration file path")
    parser.add_argument("--cleanup", action="store_true", help="Clean up old backups")
    parser.add_argument("--verbose", action="store_true", help="Enable verbose logging")
    
    args = parser.parse_args()
    
    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)
    
    # Load configuration
    config = BackupConfig(args.config)
    
    # Create backup manager
    backup_manager = BackupManager(config, args.environment)
    
    try:
        if args.cleanup:
            backup_manager.cleanup_old_backups()
        else:
            # Create backup
            backup_results = backup_manager.create_backup()
            
            # Save backup report
            report_file = backup_manager.backup_dir / f"backup_report_{backup_manager.timestamp}.json"
            with open(report_file, 'w') as f:
                json.dump(backup_results, f, indent=2)
            
            # Print summary
            summary = backup_results["summary"]
            print(f"Backup completed:")
            print(f"  Environment: {args.environment}")
            print(f"  Duration: {summary['duration']:.2f}s")
            print(f"  Total Size: {summary['total_size'] / 1024 / 1024:.2f} MB")
            print(f"  Success: {summary['success_count']}")
            print(f"  Errors: {summary['error_count']}")
            
            if summary["error_count"] > 0:
                sys.exit(1)
    
    except Exception as e:
        logger.error(f"Backup failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
