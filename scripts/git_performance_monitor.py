#!/usr/bin/env python3
"""
Git Performance Monitoring Script

This script monitors and analyzes Git operation performance, identifying bottlenecks
and providing optimization recommendations for large repositories.
"""

import os
import sys
import json
import subprocess
import datetime
import time
import statistics
from pathlib import Path
import argparse
import logging
import psutil
import threading

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('git-performance-monitor.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class GitPerformanceMonitor:
    """Monitor and analyze Git operation performance."""
    
    def __init__(self, repo_path="."):
        self.repo_path = Path(repo_path)
        self.validate_repository()
        self.performance_data = {
            "repository_info": {},
            "operation_performance": {},
            "system_metrics": {},
            "optimization_recommendations": [],
            "benchmark_results": {}
        }
        self.start_time = time.time()
    
    def validate_repository(self):
        """Validate that the path is a Git repository."""
        if not (self.repo_path / ".git").exists():
            raise ValueError(f"Not a Git repository: {self.repo_path}")
        logger.info(f"Validated Git repository at: {self.repo_path}")
    
    def run_git_command_with_timing(self, command, capture_output=True):
        """Execute Git command and measure performance."""
        start_time = time.time()
        start_memory = psutil.Process().memory_info().rss / 1024 / 1024  # MB
        
        try:
            result = subprocess.run(
                ["git"] + command,
                cwd=self.repo_path,
                capture_output=capture_output,
                text=True,
                check=True
            )
            
            end_time = time.time()
            end_memory = psutil.Process().memory_info().rss / 1024 / 1024  # MB
            
            performance_metrics = {
                "command": " ".join(command),
                "execution_time": end_time - start_time,
                "memory_usage": end_memory - start_memory,
                "success": True,
                "output_length": len(result.stdout) if capture_output else 0
            }
            
            return result.stdout.strip() if capture_output else result, performance_metrics
            
        except subprocess.CalledProcessError as e:
            end_time = time.time()
            end_memory = psutil.Process().memory_info().rss / 1024 / 1024
            
            performance_metrics = {
                "command": " ".join(command),
                "execution_time": end_time - start_time,
                "memory_usage": end_memory - start_memory,
                "success": False,
                "error": str(e)
            }
            
            logger.error(f"Git command failed: {command}, Error: {e}")
            return None, performance_metrics
    
    def get_repository_size_metrics(self):
        """Get repository size and structure metrics."""
        logger.info("Analyzing repository size and structure...")
        
        size_metrics = {}
        
        # Total repository size
        try:
            du_output = subprocess.run(
                ["du", "-sh", str(self.repo_path)],
                capture_output=True,
                text=True,
                check=True
            )
            size_metrics["total_size"] = du_output.stdout.split()[0]
        except subprocess.CalledProcessError:
            size_metrics["total_size"] = "Unknown"
        
        # .git directory size
        git_dir = self.repo_path / ".git"
        if git_dir.exists():
            try:
                git_du_output = subprocess.run(
                    ["du", "-sh", str(git_dir)],
                    capture_output=True,
                    text=True,
                    check=True
                )
                size_metrics["git_directory_size"] = git_du_output.stdout.split()[0]
            except subprocess.CalledProcessError:
                size_metrics["git_directory_size"] = "Unknown"
        
        # Count objects in .git
        try:
            git_count_output = subprocess.run(
                ["git", "count-objects", "-vH"],
                cwd=self.repo_path,
                capture_output=True,
                text=True,
                check=True
            )
            size_metrics["git_objects"] = {}
            for line in git_count_output.stdout.split('\n'):
                if ':' in line:
                    key, value = line.split(':', 1)
                    size_metrics["git_objects"][key.strip()] = value.strip()
        except subprocess.CalledProcessError:
            size_metrics["git_objects"] = {}
        
        # File count and types
        file_count = 0
        file_types = {}
        total_file_size = 0
        
        for root, dirs, files in os.walk(self.repo_path):
            if '.git' not in root:
                for file in files:
                    file_path = os.path.join(root, file)
                    try:
                        file_size = os.path.getsize(file_path)
                        file_count += 1
                        total_file_size += file_size
                        
                        ext = Path(file).suffix.lower()
                        file_types[ext] = file_types.get(ext, 0) + 1
                    except OSError:
                        continue
        
        size_metrics["working_tree_files"] = file_count
        size_metrics["working_tree_size"] = f"{total_file_size / 1024 / 1024:.2f} MB"
        size_metrics["file_types"] = dict(sorted(file_types.items(), key=lambda x: x[1], reverse=True)[:10])
        
        self.performance_data["repository_info"]["size_metrics"] = size_metrics
        logger.info(f"Repository size analysis completed: {size_metrics['total_size']}")
    
    def benchmark_git_operations(self):
        """Benchmark common Git operations."""
        logger.info("Benchmarking Git operations...")
        
        operations = [
            (["status"], "git status"),
            (["log", "--oneline", "-n", "10"], "git log (10 commits)"),
            (["log", "--oneline", "-n", "100"], "git log (100 commits)"),
            (["diff", "--stat"], "git diff --stat"),
            (["diff", "--name-only"], "git diff --name-only"),
            (["branch", "-a"], "git branch -a"),
            (["tag"], "git tag"),
            (["ls-files"], "git ls-files"),
            (["rev-list", "--count", "HEAD"], "git rev-list --count"),
            (["show", "--stat", "HEAD"], "git show --stat HEAD"),
        ]
        
        benchmark_results = {}
        
        for command, description in operations:
            logger.info(f"Benchmarking: {description}")
            output, metrics = self.run_git_command_with_timing(command)
            
            benchmark_results[description] = {
                "execution_time": metrics["execution_time"],
                "memory_usage": metrics["memory_usage"],
                "success": metrics["success"]
            }
            
            if not metrics["success"]:
                logger.warning(f"Operation failed: {description}")
        
        # Benchmark more intensive operations
        intensive_operations = [
            (["log", "--stat", "-n", "50"], "git log --stat (50 commits)"),
            (["blame", "README.md"], "git blame README.md"),
            (["pack-refs", "--all"], "git pack-refs --all"),
            (["gc", "--auto"], "git gc --auto"),
        ]
        
        for command, description in intensive_operations:
            logger.info(f"Benchmarking intensive: {description}")
            output, metrics = self.run_git_command_with_timing(command)
            
            benchmark_results[description] = {
                "execution_time": metrics["execution_time"],
                "memory_usage": metrics["memory_usage"],
                "success": metrics["success"]
            }
        
        self.performance_data["benchmark_results"] = benchmark_results
        logger.info(f"Benchmark completed: {len(benchmark_results)} operations tested")
    
    def analyze_system_performance(self):
        """Analyze system performance during Git operations."""
        logger.info("Analyzing system performance...")
        
        system_metrics = {}
        
        # CPU and Memory usage
        cpu_percent = psutil.cpu_percent(interval=1)
        memory = psutil.virtual_memory()
        disk = psutil.disk_usage(str(self.repo_path))
        
        system_metrics["cpu_usage"] = cpu_percent
        system_metrics["memory_usage"] = {
            "total": f"{memory.total / 1024 / 1024 / 1024:.2f} GB",
            "available": f"{memory.available / 1024 / 1024 / 1024:.2f} GB",
            "percent": memory.percent
        }
        system_metrics["disk_usage"] = {
            "total": f"{disk.total / 1024 / 1024 / 1024:.2f} GB",
            "free": f"{disk.free / 1024 / 1024 / 1024:.2f} GB",
            "percent": (disk.used / disk.total) * 100
        }
        
        # I/O statistics
        try:
            io_stats = psutil.disk_io_counters()
            system_metrics["io_stats"] = {
                "read_count": io_stats.read_count,
                "write_count": io_stats.write_count,
                "read_bytes": io_stats.read_bytes,
                "write_bytes": io_stats.write_bytes
            }
        except AttributeError:
            system_metrics["io_stats"] = "Not available"
        
        # Process information
        process = psutil.Process()
        system_metrics["process_info"] = {
            "pid": process.pid,
            "memory_percent": process.memory_percent(),
            "cpu_percent": process.cpu_percent(),
            "num_threads": process.num_threads(),
            "create_time": datetime.datetime.fromtimestamp(process.create_time()).isoformat()
        }
        
        self.performance_data["system_metrics"] = system_metrics
        logger.info("System performance analysis completed")
    
    def analyze_git_configuration(self):
        """Analyze Git configuration for performance impact."""
        logger.info("Analyzing Git configuration...")
        
        config_analysis = {}
        
        # Get Git configuration
        config_output = self.run_git_command_with_timing(["config", "--list", "--show-origin"])
        if config_output[0]:
            config_lines = config_output[0].split('\n')
            
            performance_configs = {}
            for line in config_lines:
                if '=' in line:
                    key, value = line.split('=', 1)
                    if any(perf_key in key.lower() for perf_key in [
                        'core.packedgitlimit', 'core.deltabaselimit', 'pack.packsize',
                        'pack.window', 'pack.depth', 'pack.indexversion', 'core.compression',
                        'pack.threads', 'core.loosecompression', 'pack.compression'
                    ]):
                        performance_configs[key.strip()] = value.strip()
            
            config_analysis["performance_settings"] = performance_configs
        
        # Check for large file handling
        large_file_configs = {}
        for key, value in performance_configs.items():
            if 'large' in key.lower() or 'lfs' in key.lower():
                large_file_configs[key] = value
        
        config_analysis["large_file_handling"] = large_file_configs
        
        # Check for optimization settings
        optimization_configs = {}
        for key, value in performance_configs.items():
            if any(opt_key in key.lower() for opt_key in [
                'core.preloadindex', 'core.fscache', 'core.untrackedcache',
                'gc.auto', 'gc.autopacklimit', 'gc.aggressivewindow'
            ]):
                optimization_configs[key] = value
        
        config_analysis["optimization_settings"] = optimization_configs
        
        self.performance_data["repository_info"]["configuration"] = config_analysis
        logger.info("Git configuration analysis completed")
    
    def generate_optimization_recommendations(self):
        """Generate performance optimization recommendations."""
        logger.info("Generating optimization recommendations...")
        
        recommendations = []
        
        size_metrics = self.performance_data["repository_info"].get("size_metrics", {})
        benchmark_results = self.performance_data.get("benchmark_results", {})
        config_analysis = self.performance_data["repository_info"].get("configuration", {})
        
        # Repository size recommendations
        total_size = size_metrics.get("total_size", "0")
        if "GB" in total_size and float(total_size.split()[0].replace("GB", "")) > 1:
            recommendations.append({
                "category": "Repository Size",
                "priority": "High",
                "issue": "Large repository size detected",
                "recommendation": "Consider using Git LFS for large files and cleaning up unnecessary files",
                "commands": [
                    "git lfs install",
                    "git lfs track '*.zip'",
                    "git lfs track '*.bin'",
                    "git add .gitattributes",
                    "git gc --aggressive --prune=now"
                ]
            })
        
        # Performance recommendations based on benchmarks
        slow_operations = []
        for operation, metrics in benchmark_results.items():
            if metrics["execution_time"] > 5.0:  # Operations taking more than 5 seconds
                slow_operations.append((operation, metrics["execution_time"]))
        
        if slow_operations:
            slow_operations.sort(key=lambda x: x[1], reverse=True)
            recommendations.append({
                "category": "Performance",
                "priority": "Medium",
                "issue": f"Slow operations detected: {slow_operations[0][0]} ({slow_operations[0][1]:.2f}s)",
                "recommendation": "Optimize Git configuration and consider repository cleanup",
                "commands": [
                    "git config --global core.preloadindex true",
                    "git config --global core.fscache true",
                    "git config --global gc.auto 256",
                    "git repack -a -d --depth=250 --window=250"
                ]
            })
        
        # Configuration recommendations
        perf_settings = config_analysis.get("performance_settings", {})
        if not perf_settings:
            recommendations.append({
                "category": "Configuration",
                "priority": "Medium",
                "issue": "No performance-specific Git configuration found",
                "recommendation": "Configure Git for better performance with large repositories",
                "commands": [
                    "git config --global core.packedgitlimit 512k",
                    "git config --global core.deltabaselimit 2048",
                    "git config --global pack.packsize 512m",
                    "git config --global pack.window 1k",
                    "git config --global pack.threads 4"
                ]
            })
        
        # Memory usage recommendations
        system_metrics = self.performance_data.get("system_metrics", {})
        memory_percent = system_metrics.get("memory_usage", {}).get("percent", 0)
        if memory_percent > 80:
            recommendations.append({
                "category": "System Resources",
                "priority": "High",
                "issue": f"High memory usage: {memory_percent}%",
                "recommendation": "Optimize memory usage and consider system upgrades",
                "commands": [
                    "git config --global core.packedgitlimit 128m",
                    "git config --global pack.deltacachesize 512m",
                    "git config --global pack.memory 512m"
                ]
            })
        
        # Git LFS recommendations
        large_file_handling = config_analysis.get("large_file_handling", {})
        if not large_file_handling and "GB" in total_size:
            recommendations.append({
                "category": "Large Files",
                "priority": "Medium",
                "issue": "Large files detected without Git LFS configuration",
                "recommendation": "Set up Git LFS for better handling of large files",
                "commands": [
                    "git lfs install",
                    "git lfs track '*.psd'",
                    "git lfs track '*.zip'",
                    "git lfs track '*.bin'",
                    "git lfs track '*.exe'"
                ]
            })
        
        self.performance_data["optimization_recommendations"] = recommendations
        logger.info(f"Generated {len(recommendations)} optimization recommendations")
    
    def generate_performance_report(self, output_format="json", output_file=None):
        """Generate comprehensive performance report."""
        logger.info("Generating performance report...")
        
        # Add metadata
        self.performance_data["report_metadata"] = {
            "generated_at": datetime.datetime.now().isoformat(),
            "analysis_duration": time.time() - self.start_time,
            "monitor_version": "1.0.0"
        }
        
        if output_format.lower() == "json":
            report = json.dumps(self.performance_data, indent=2, default=str)
        elif output_format.lower() == "summary":
            report = self.generate_summary_report()
        else:
            report = json.dumps(self.performance_data, indent=2, default=str)
        
        if output_file:
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(report)
            logger.info(f"Performance report saved to: {output_file}")
        
        return report
    
    def generate_summary_report(self):
        """Generate a human-readable performance summary."""
        summary = []
        summary.append("# Git Performance Monitoring Report")
        summary.append(f"Generated on: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        summary.append(f"Analysis Duration: {self.performance_data.get('report_metadata', {}).get('analysis_duration', 0):.2f} seconds")
        summary.append("")
        
        # Repository Overview
        size_metrics = self.performance_data["repository_info"].get("size_metrics", {})
        summary.append("## Repository Overview")
        summary.append(f"- **Total Size**: {size_metrics.get('total_size', 'N/A')}")
        summary.append(f"- **Git Directory Size**: {size_metrics.get('git_directory_size', 'N/A')}")
        summary.append(f"- **Working Tree Files**: {size_metrics.get('working_tree_files', 'N/A')}")
        summary.append(f"- **Working Tree Size**: {size_metrics.get('working_tree_size', 'N/A')}")
        summary.append("")
        
        # Performance Benchmarks
        benchmark_results = self.performance_data.get("benchmark_results", {})
        if benchmark_results:
            summary.append("## Performance Benchmarks")
            
            # Sort by execution time
            sorted_benchmarks = sorted(benchmark_results.items(), key=lambda x: x[1]["execution_time"], reverse=True)
            
            for operation, metrics in sorted_benchmarks[:10]:  # Top 10 slowest
                status = "✅" if metrics["success"] else "❌"
                summary.append(f"- {status} **{operation}**: {metrics['execution_time']:.3f}s")
            summary.append("")
        
        # System Metrics
        system_metrics = self.performance_data.get("system_metrics", {})
        if system_metrics:
            summary.append("## System Metrics")
            summary.append(f"- **CPU Usage**: {system_metrics.get('cpu_usage', 'N/A')}%")
            summary.append(f"- **Memory Usage**: {system_metrics.get('memory_usage', {}).get('percent', 'N/A')}%")
            summary.append(f"- **Disk Usage**: {system_metrics.get('disk_usage', {}).get('percent', 'N/A'):.1f}%")
            summary.append("")
        
        # Optimization Recommendations
        recommendations = self.performance_data.get("optimization_recommendations", [])
        if recommendations:
            summary.append("## Optimization Recommendations")
            
            # Group by priority
            high_priority = [r for r in recommendations if r["priority"] == "High"]
            medium_priority = [r for r in recommendations if r["priority"] == "Medium"]
            low_priority = [r for r in recommendations if r["priority"] == "Low"]
            
            if high_priority:
                summary.append("### High Priority")
                for rec in high_priority:
                    summary.append(f"- **{rec['category']}**: {rec['issue']}")
                    summary.append(f"  - Recommendation: {rec['recommendation']}")
                summary.append("")
            
            if medium_priority:
                summary.append("### Medium Priority")
                for rec in medium_priority:
                    summary.append(f"- **{rec['category']}**: {rec['issue']}")
                    summary.append(f"  - Recommendation: {rec['recommendation']}")
                summary.append("")
            
            if low_priority:
                summary.append("### Low Priority")
                for rec in low_priority:
                    summary.append(f"- **{rec['category']}**: {rec['issue']}")
                    summary.append(f"  - Recommendation: {rec['recommendation']}")
                summary.append("")
        
        # Performance Score
        summary.append("## Performance Score")
        
        # Calculate a simple performance score
        score = 100
        if recommendations:
            high_count = len([r for r in recommendations if r["priority"] == "High"])
            medium_count = len([r for r in recommendations if r["priority"] == "Medium"])
            low_count = len([r for r in recommendations if r["priority"] == "Low"])
            
            score -= (high_count * 20) + (medium_count * 10) + (low_count * 5)
            score = max(0, score)
        
        summary.append(f"**Overall Performance Score**: {score}/100")
        
        if score >= 80:
            summary.append("🟢 **Excellent** - Repository performance is optimal")
        elif score >= 60:
            summary.append("🟡 **Good** - Some optimizations recommended")
        elif score >= 40:
            summary.append("🟠 **Fair** - Several optimizations needed")
        else:
            summary.append("🔴 **Poor** - Significant optimizations required")
        
        summary.append("")
        
        return "\n".join(summary)

def main():
    """Main function to run the Git performance monitor."""
    parser = argparse.ArgumentParser(description="Git Performance Monitoring")
    parser.add_argument("--repo-path", default=".", help="Path to Git repository (default: current directory)")
    parser.add_argument("--output-format", choices=["json", "summary"], default="summary", help="Output format (default: summary)")
    parser.add_argument("--output-file", help="Output file path (default: stdout)")
    parser.add_argument("--verbose", action="store_true", help="Enable verbose logging")
    
    args = parser.parse_args()
    
    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)
    
    try:
        # Initialize monitor
        monitor = GitPerformanceMonitor(args.repo_path)
        
        # Run all analyses
        monitor.get_repository_size_metrics()
        monitor.analyze_git_configuration()
        monitor.benchmark_git_operations()
        monitor.analyze_system_performance()
        monitor.generate_optimization_recommendations()
        
        # Generate report
        report = monitor.generate_performance_report(args.output_format, args.output_file)
        
        if not args.output_file:
            print(report)
        
        logger.info("Git performance monitoring completed successfully")
        
    except Exception as e:
        logger.error(f"Performance monitoring failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
