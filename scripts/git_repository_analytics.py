#!/usr/bin/env python3
"""
Advanced Git Repository Analytics and Monitoring Script

This script provides comprehensive analysis and monitoring capabilities for Git repositories,
including commit analysis, contributor statistics, code quality metrics, and repository health assessment.
"""

import os
import sys
import json
import subprocess
import datetime
import statistics
from collections import defaultdict, Counter
from pathlib import Path
import argparse
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('git-repository-analytics.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class GitRepositoryAnalyzer:
    """Advanced Git repository analyzer with comprehensive metrics."""
    
    def __init__(self, repo_path="."):
        self.repo_path = Path(repo_path)
        self.validate_repository()
        self.analytics_data = {
            "repository_info": {},
            "commit_analysis": {},
            "contributor_stats": {},
            "code_metrics": {},
            "branch_analysis": {},
            "tag_analysis": {},
            "file_analysis": {},
            "health_metrics": {},
            "trend_analysis": {}
        }
    
    def validate_repository(self):
        """Validate that the path is a Git repository."""
        if not (self.repo_path / ".git").exists():
            raise ValueError(f"Not a Git repository: {self.repo_path}")
        logger.info(f"Validated Git repository at: {self.repo_path}")
    
    def run_git_command(self, command, capture_output=True):
        """Execute Git command and return output."""
        try:
            result = subprocess.run(
                ["git"] + command,
                cwd=self.repo_path,
                capture_output=capture_output,
                text=True,
                check=True
            )
            return result.stdout.strip() if capture_output else result
        except subprocess.CalledProcessError as e:
            logger.error(f"Git command failed: {command}, Error: {e}")
            return None
    
    def get_repository_info(self):
        """Get basic repository information."""
        logger.info("Collecting repository information...")
        
        info = {}
        
        # Remote information
        remotes = self.run_git_command(["remote", "-v"])
        info["remotes"] = remotes.split('\n') if remotes else []
        
        # Current branch
        current_branch = self.run_git_command(["branch", "--show-current"])
        info["current_branch"] = current_branch
        
        # Repository size
        try:
            size_output = subprocess.run(
                ["du", "-sh", str(self.repo_path)],
                capture_output=True,
                text=True,
                check=True
            )
            info["repository_size"] = size_output.stdout.split()[0]
        except subprocess.CalledProcessError:
            info["repository_size"] = "Unknown"
        
        # Total commits
        total_commits = self.run_git_command(["rev-list", "--count", "HEAD"])
        info["total_commits"] = int(total_commits) if total_commits else 0
        
        # First and last commit dates
        first_commit_date = self.run_git_command(
            ["log", "--reverse", "--format=%ci", "HEAD", "-n", "1"]
        )
        last_commit_date = self.run_git_command(
            ["log", "--format=%ci", "HEAD", "-n", "1"]
        )
        
        info["first_commit_date"] = first_commit_date
        info["last_commit_date"] = last_commit_date
        
        # Repository age in days
        if first_commit_date:
            first_date = datetime.datetime.strptime(first_commit_date.split()[0], "%Y-%m-%d")
            age_days = (datetime.datetime.now() - first_date).days
            info["repository_age_days"] = age_days
        
        self.analytics_data["repository_info"] = info
        logger.info(f"Repository info collected: {info['total_commits']} commits, {info.get('repository_age_days', 'Unknown')} days old")
    
    def analyze_commits(self, days_back=90):
        """Analyze commit patterns and trends."""
        logger.info(f"Analyzing commits for the last {days_back} days...")
        
        # Get commits in the specified time range
        since_date = (datetime.datetime.now() - datetime.timedelta(days=days_back)).strftime("%Y-%m-%d")
        commits = self.run_git_command([
            "log", f"--since={since_date}", "--format=%H|%an|%ad|%s",
            "--date=short"
        ])
        
        if not commits:
            logger.warning("No commits found in the specified time range")
            return
        
        commit_data = []
        daily_commits = defaultdict(int)
        hourly_commits = defaultdict(int)
        author_commits = defaultdict(int)
        commit_lengths = []
        
        for line in commits.split('\n'):
            if line.strip():
                parts = line.split('|')
                if len(parts) >= 4:
                    commit_hash, author, date, subject = parts[:4]
                    commit_date = datetime.datetime.strptime(date, "%Y-%m-%d")
                    
                    commit_data.append({
                        "hash": commit_hash,
                        "author": author,
                        "date": date,
                        "subject": subject,
                        "day_of_week": commit_date.weekday(),
                        "hour": commit_date.hour
                    })
                    
                    daily_commits[date] += 1
                    hourly_commits[commit_date.hour] += 1
                    author_commits[author] += 1
                    commit_lengths.append(len(subject))
        
        # Calculate statistics
        commit_analysis = {
            "total_commits_period": len(commit_data),
            "daily_average": statistics.mean(daily_commits.values()) if daily_commits else 0,
            "most_active_day": max(daily_commits.items(), key=lambda x: x[1])[0] if daily_commits else None,
            "most_active_hour": max(hourly_commits.items(), key=lambda x: x[1])[0] if hourly_commits else None,
            "average_commit_message_length": statistics.mean(commit_lengths) if commit_lengths else 0,
            "commit_frequency_by_day": dict(daily_commits),
            "commit_frequency_by_hour": dict(hourly_commits),
            "top_authors": dict(sorted(author_commits.items(), key=lambda x: x[1], reverse=True)[:10])
        }
        
        self.analytics_data["commit_analysis"] = commit_analysis
        logger.info(f"Commit analysis completed: {commit_analysis['total_commits_period']} commits analyzed")
    
    def analyze_contributors(self):
        """Analyze contributor statistics and activity."""
        logger.info("Analyzing contributor statistics...")
        
        # Get all contributors with their statistics
        contributor_stats = self.run_git_command([
            "shortlog", "-sn", "--all"
        ])
        
        contributors = []
        total_commits = 0
        
        for line in contributor_stats.split('\n'):
            if line.strip():
                parts = line.strip().split('\t')
                if len(parts) >= 2:
                    commits, name = parts[:2]
                    contributors.append({
                        "name": name,
                        "commits": int(commits)
                    })
                    total_commits += int(commits)
        
        # Get detailed contributor information
        detailed_contributors = []
        for contributor in contributors:
            # Get first and last commit dates for each contributor
            first_commit = self.run_git_command([
                "log", "--author", contributor["name"], "--reverse", "--format=%ad", "-n", "1", "--date=short"
            ])
            last_commit = self.run_git_command([
                "log", "--author", contributor["name"], "--format=%ad", "-n", "1", "--date=short"
            ])
            
            # Get files changed by contributor
            files_changed = self.run_git_command([
                "log", "--author", contributor["name"], "--name-only", "--pretty=format:" | sort -u
            ])
            
            # Get commit message patterns
            commit_messages = self.run_git_command([
                "log", "--author", contributor["name"], "--format=%s"
            ])
            
            detailed_contributors.append({
                "name": contributor["name"],
                "commits": contributor["commits"],
                "contribution_percentage": round((contributor["commits"] / total_commits) * 100, 2) if total_commits > 0 else 0,
                "first_commit": first_commit,
                "last_commit": last_commit,
                "files_changed": len(files_changed.split('\n')) if files_changed else 0,
                "average_message_length": statistics.mean([len(msg) for msg in commit_messages.split('\n') if msg]) if commit_messages else 0
            })
        
        # Sort by contribution percentage
        detailed_contributors.sort(key=lambda x: x["contribution_percentage"], reverse=True)
        
        self.analytics_data["contributor_stats"] = {
            "total_contributors": len(detailed_contributors),
            "total_commits": total_commits,
            "top_contributors": detailed_contributors[:10],
            "contributor_distribution": {
                "top_10_percent": sum(1 for c in detailed_contributors if c["contribution_percentage"] >= 10),
                "between_5_10_percent": sum(1 for c in detailed_contributors if 5 <= c["contribution_percentage"] < 10),
                "between_1_5_percent": sum(1 for c in detailed_contributors if 1 <= c["contribution_percentage"] < 5),
                "less_than_1_percent": sum(1 for c in detailed_contributors if c["contribution_percentage"] < 1)
            }
        }
        
        logger.info(f"Contributor analysis completed: {len(detailed_contributors)} contributors analyzed")
    
    def analyze_code_metrics(self):
        """Analyze code quality and complexity metrics."""
        logger.info("Analyzing code metrics...")
        
        # Get file statistics
        file_stats = self.run_git_command(["ls-files"])
        files = file_stats.split('\n') if file_stats else []
        
        file_extensions = Counter()
        file_sizes = defaultdict(list)
        total_lines = 0
        total_files = len(files)
        
        for file_path in files:
            if os.path.exists(os.path.join(self.repo_path, file_path)):
                try:
                    # Get file extension
                    ext = Path(file_path).suffix.lower()
                    file_extensions[ext] += 1
                    
                    # Get file size
                    size = os.path.getsize(os.path.join(self.repo_path, file_path))
                    file_sizes[ext].append(size)
                    
                    # Get line count for text files
                    if ext in ['.dart', '.py', '.js', '.ts', '.java', '.kt', '.md', '.yaml', '.yml', '.json']:
                        try:
                            with open(os.path.join(self.repo_path, file_path), 'r', encoding='utf-8') as f:
                                lines = len(f.readlines())
                                total_lines += lines
                        except (UnicodeDecodeError, IOError):
                            pass
                except OSError:
                    continue
        
        # Calculate code metrics
        code_metrics = {
            "total_files": total_files,
            "total_lines_of_code": total_lines,
            "file_extensions": dict(file_extensions.most_common(10)),
            "average_file_size": statistics.mean([size for sizes in file_sizes.values() for size in sizes]) if file_sizes else 0,
            "largest_files": [],
            "code_complexity": {}
        }
        
        # Get largest files
        all_files_with_sizes = []
        for ext, sizes in file_sizes.items():
            for size in sizes:
                all_files_with_sizes.append((ext, size))
        
        all_files_with_sizes.sort(key=lambda x: x[1], reverse=True)
        code_metrics["largest_files"] = all_files_with_sizes[:10]
        
        # Language-specific metrics
        dart_files = [f for f in files if f.endswith('.dart')]
        if dart_files:
            # Basic Dart metrics
            code_metrics["code_complexity"]["dart"] = {
                "total_dart_files": len(dart_files),
                "average_lines_per_file": total_lines // len(dart_files) if dart_files else 0
            }
        
        self.analytics_data["code_metrics"] = code_metrics
        logger.info(f"Code metrics analysis completed: {total_files} files, {total_lines} lines of code")
    
    def analyze_branches(self):
        """Analyze branch information and health."""
        logger.info("Analyzing branches...")
        
        # Get all branches
        branches_output = self.run_git_command(["branch", "-a"])
        branches = []
        
        for line in branches_output.split('\n'):
            if line.strip():
                branch_name = line.strip().replace('* ', '').replace('remotes/', '')
                branches.append(branch_name)
        
        branch_analysis = {
            "total_branches": len(branches),
            "local_branches": len([b for b in branches if not b.startswith('origin/')]),
            "remote_branches": len([b for b in branches if b.startswith('origin/')]),
            "branches": []
        }
        
        # Analyze each branch
        for branch in branches[:20]:  # Limit to first 20 branches
            # Get commit count for branch
            commit_count = self.run_git_command(["rev-list", "--count", branch])
            
            # Get last commit date
            last_commit = self.run_git_command(["log", "-n", "1", "--format=%ci", branch])
            
            # Check if branch is merged
            is_merged = self.run_git_command(["merge-base", "--is-ancestor", branch, "HEAD"], capture_output=False)
            merged_status = is_merged.returncode == 0
            
            branch_analysis["branches"].append({
                "name": branch,
                "commit_count": int(commit_count) if commit_count else 0,
                "last_commit": last_commit,
                "is_merged": merged_status
            })
        
        self.analytics_data["branch_analysis"] = branch_analysis
        logger.info(f"Branch analysis completed: {branch_analysis['total_branches']} branches analyzed")
    
    def analyze_tags(self):
        """Analyze tag information and release patterns."""
        logger.info("Analyzing tags...")
        
        # Get all tags
        tags_output = self.run_git_command(["tag", "--sort=-version:refname"])
        tags = tags_output.split('\n') if tags_output else []
        
        tag_analysis = {
            "total_tags": len(tags),
            "recent_tags": [],
            "release_patterns": {}
        }
        
        # Analyze recent tags
        for tag in tags[:20]:  # Limit to first 20 tags
            # Get tag date
            tag_date = self.run_git_command(["log", "-n", "1", "--format=%ci", tag])
            
            # Get commit message for tag
            tag_message = self.run_git_command(["tag", "-l", "--format=%(contents)", tag])
            
            tag_analysis["recent_tags"].append({
                "name": tag,
                "date": tag_date,
                "message": tag_message
            })
        
        # Analyze release patterns
        if tags:
            # Extract version patterns
            version_tags = [tag for tag in tags if tag.startswith('v')]
            if version_tags:
                tag_analysis["release_patterns"]["semantic_versioning"] = True
                tag_analysis["release_patterns"]["latest_version"] = version_tags[0]
                tag_analysis["release_patterns"]["total_releases"] = len(version_tags)
        
        self.analytics_data["tag_analysis"] = tag_analysis
        logger.info(f"Tag analysis completed: {tag_analysis['total_tags']} tags analyzed")
    
    def calculate_health_metrics(self):
        """Calculate repository health metrics."""
        logger.info("Calculating repository health metrics...")
        
        health_metrics = {
            "overall_health_score": 0,
            "activity_score": 0,
            "contributor_diversity": 0,
            "code_quality": 0,
            "maintenance_score": 0,
            "recommendations": []
        }
        
        repo_info = self.analytics_data.get("repository_info", {})
        commit_analysis = self.analytics_data.get("commit_analysis", {})
        contributor_stats = self.analytics_data.get("contributor_stats", {})
        code_metrics = self.analytics_data.get("code_metrics", {})
        
        # Activity score (based on recent commits)
        if commit_analysis.get("total_commits_period", 0) > 0:
            daily_avg = commit_analysis.get("daily_average", 0)
            if daily_avg >= 5:
                health_metrics["activity_score"] = 100
            elif daily_avg >= 2:
                health_metrics["activity_score"] = 80
            elif daily_avg >= 1:
                health_metrics["activity_score"] = 60
            else:
                health_metrics["activity_score"] = 40
        else:
            health_metrics["activity_score"] = 0
            health_metrics["recommendations"].append("Low activity - consider increasing commit frequency")
        
        # Contributor diversity
        total_contributors = contributor_stats.get("total_contributors", 0)
        if total_contributors >= 10:
            health_metrics["contributor_diversity"] = 100
        elif total_contributors >= 5:
            health_metrics["contributor_diversity"] = 80
        elif total_contributors >= 3:
            health_metrics["contributor_diversity"] = 60
        elif total_contributors >= 2:
            health_metrics["contributor_diversity"] = 40
        else:
            health_metrics["contributor_diversity"] = 20
            health_metrics["recommendations"].append("Low contributor diversity - encourage more contributors")
        
        # Code quality (simplified metric based on file structure)
        total_files = code_metrics.get("total_files", 0)
        if total_files > 0:
            dart_files = code_metrics.get("file_extensions", {}).get('.dart', 0)
            if dart_files > 0:
                health_metrics["code_quality"] = 80  # Basic structure exists
            else:
                health_metrics["code_quality"] = 60
        else:
            health_metrics["code_quality"] = 0
            health_metrics["recommendations"].append("No source files found")
        
        # Maintenance score (based on recent activity and branching)
        branch_analysis = self.analytics_data.get("branch_analysis", {})
        if commit_analysis.get("total_commits_period", 0) > 0 and branch_analysis.get("total_branches", 0) > 1:
            health_metrics["maintenance_score"] = 80
        else:
            health_metrics["maintenance_score"] = 60
        
        # Calculate overall health score
        scores = [
            health_metrics["activity_score"],
            health_metrics["contributor_diversity"],
            health_metrics["code_quality"],
            health_metrics["maintenance_score"]
        ]
        health_metrics["overall_health_score"] = round(statistics.mean(scores))
        
        self.analytics_data["health_metrics"] = health_metrics
        logger.info(f"Health metrics calculated: overall score {health_metrics['overall_health_score']}")
    
    def generate_trend_analysis(self):
        """Generate trend analysis and predictions."""
        logger.info("Generating trend analysis...")
        
        commit_analysis = self.analytics_data.get("commit_analysis", {})
        contributor_stats = self.analytics_data.get("contributor_stats", {})
        
        trend_analysis = {
            "activity_trend": "stable",
            "contributor_trend": "stable",
            "growth_prediction": {},
            "recommendations": []
        }
        
        # Activity trend analysis
        daily_commits = commit_analysis.get("commit_frequency_by_day", {})
        if len(daily_commits) >= 7:
            recent_week = list(daily_commits.values())[-7:]
            if len(recent_week) >= 7:
                avg_recent = statistics.mean(recent_week)
                if avg_recent > 5:
                    trend_analysis["activity_trend"] = "increasing"
                elif avg_recent < 1:
                    trend_analysis["activity_trend"] = "decreasing"
                else:
                    trend_analysis["activity_trend"] = "stable"
        
        # Contributor trend
        top_contributors = contributor_stats.get("top_contributors", [])
        if len(top_contributors) >= 3:
            active_contributors = len([c for c in top_contributors if c.get("commits", 0) > 0])
            if active_contributors >= 5:
                trend_analysis["contributor_trend"] = "growing"
            elif active_contributors <= 2:
                trend_analysis["contributor_trend"] = "declining"
            else:
                trend_analysis["contributor_trend"] = "stable"
        
        # Growth prediction (simplified)
        total_commits = self.analytics_data.get("repository_info", {}).get("total_commits", 0)
        repo_age = self.analytics_data.get("repository_info", {}).get("repository_age_days", 1)
        
        if repo_age > 0:
            commits_per_day = total_commits / repo_age
            trend_analysis["growth_prediction"] = {
                "current_rate": round(commits_per_day, 2),
                "predicted_commits_next_month": round(commits_per_day * 30),
                "predicted_commits_next_year": round(commits_per_day * 365)
            }
        
        self.analytics_data["trend_analysis"] = trend_analysis
        logger.info("Trend analysis completed")
    
    def generate_report(self, output_format="json", output_file=None):
        """Generate comprehensive analytics report."""
        logger.info("Generating comprehensive report...")
        
        # Add timestamp to analytics data
        self.analytics_data["report_generated_at"] = datetime.datetime.now().isoformat()
        self.analytics_data["analyzer_version"] = "1.0.0"
        
        if output_format.lower() == "json":
            report = json.dumps(self.analytics_data, indent=2, default=str)
        elif output_format.lower() == "summary":
            report = self.generate_summary_report()
        else:
            report = json.dumps(self.analytics_data, indent=2, default=str)
        
        if output_file:
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(report)
            logger.info(f"Report saved to: {output_file}")
        
        return report
    
    def generate_summary_report(self):
        """Generate a human-readable summary report."""
        summary = []
        summary.append("# Git Repository Analytics Report")
        summary.append(f"Generated on: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        summary.append("")
        
        # Repository Overview
        repo_info = self.analytics_data.get("repository_info", {})
        summary.append("## Repository Overview")
        summary.append(f"- **Total Commits**: {repo_info.get('total_commits', 'N/A')}")
        summary.append(f"- **Repository Age**: {repo_info.get('repository_age_days', 'N/A')} days")
        summary.append(f"- **Repository Size**: {repo_info.get('repository_size', 'N/A')}")
        summary.append(f"- **Current Branch**: {repo_info.get('current_branch', 'N/A')}")
        summary.append("")
        
        # Health Metrics
        health = self.analytics_data.get("health_metrics", {})
        summary.append("## Health Metrics")
        summary.append(f"- **Overall Health Score**: {health.get('overall_health_score', 'N/A')}/100")
        summary.append(f"- **Activity Score**: {health.get('activity_score', 'N/A')}/100")
        summary.append(f"- **Contributor Diversity**: {health.get('contributor_diversity', 'N/A')}/100")
        summary.append(f"- **Code Quality**: {health.get('code_quality', 'N/A')}/100")
        summary.append("")
        
        # Recommendations
        if health.get("recommendations"):
            summary.append("## Recommendations")
            for rec in health["recommendations"]:
                summary.append(f"- {rec}")
            summary.append("")
        
        # Recent Activity
        commit_analysis = self.analytics_data.get("commit_analysis", {})
        summary.append("## Recent Activity (Last 90 Days)")
        summary.append(f"- **Total Commits**: {commit_analysis.get('total_commits_period', 'N/A')}")
        summary.append(f"- **Daily Average**: {commit_analysis.get('daily_average', 'N/A'):.2f}")
        summary.append(f"- **Most Active Day**: {commit_analysis.get('most_active_day', 'N/A')}")
        summary.append(f"- **Most Active Hour**: {commit_analysis.get('most_active_hour', 'N/A')}:00")
        summary.append("")
        
        # Contributors
        contributor_stats = self.analytics_data.get("contributor_stats", {})
        summary.append("## Contributors")
        summary.append(f"- **Total Contributors**: {contributor_stats.get('total_contributors', 'N/A')}")
        summary.append("")
        
        top_contributors = contributor_stats.get("top_contributors", [])[:5]
        if top_contributors:
            summary.append("### Top Contributors")
            for contributor in top_contributors:
                summary.append(f"- **{contributor.get('name', 'N/A')}**: {contributor.get('commits', 'N/A')} commits ({contributor.get('contribution_percentage', 'N/A')}%)")
            summary.append("")
        
        # Code Metrics
        code_metrics = self.analytics_data.get("code_metrics", {})
        summary.append("## Code Metrics")
        summary.append(f"- **Total Files**: {code_metrics.get('total_files', 'N/A')}")
        summary.append(f"- **Total Lines of Code**: {code_metrics.get('total_lines_of_code', 'N/A')}")
        summary.append("")
        
        file_extensions = code_metrics.get("file_extensions", {})
        if file_extensions:
            summary.append("### File Extensions")
            for ext, count in list(file_extensions.items())[:5]:
                summary.append(f"- **{ext or 'no extension'}**: {count} files")
            summary.append("")
        
        # Trends
        trends = self.analytics_data.get("trend_analysis", {})
        summary.append("## Trend Analysis")
        summary.append(f"- **Activity Trend**: {trends.get('activity_trend', 'N/A')}")
        summary.append(f"- **Contributor Trend**: {trends.get('contributor_trend', 'N/A')}")
        
        growth_pred = trends.get("growth_prediction", {})
        if growth_pred:
            summary.append(f"- **Current Rate**: {growth_pred.get('current_rate', 'N/A')} commits/day")
            summary.append(f"- **Predicted Next Month**: {growth_pred.get('predicted_commits_next_month', 'N/A')} commits")
        summary.append("")
        
        return "\n".join(summary)

def main():
    """Main function to run the Git repository analyzer."""
    parser = argparse.ArgumentParser(description="Advanced Git Repository Analytics")
    parser.add_argument("--repo-path", default=".", help="Path to Git repository (default: current directory)")
    parser.add_argument("--days-back", type=int, default=90, help="Number of days to analyze (default: 90)")
    parser.add_argument("--output-format", choices=["json", "summary"], default="json", help="Output format (default: json)")
    parser.add_argument("--output-file", help="Output file path (default: stdout)")
    parser.add_argument("--verbose", action="store_true", help="Enable verbose logging")
    
    args = parser.parse_args()
    
    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)
    
    try:
        # Initialize analyzer
        analyzer = GitRepositoryAnalyzer(args.repo_path)
        
        # Run all analyses
        analyzer.get_repository_info()
        analyzer.analyze_commits(args.days_back)
        analyzer.analyze_contributors()
        analyzer.analyze_code_metrics()
        analyzer.analyze_branches()
        analyzer.analyze_tags()
        analyzer.calculate_health_metrics()
        analyzer.generate_trend_analysis()
        
        # Generate report
        report = analyzer.generate_report(args.output_format, args.output_file)
        
        if not args.output_file:
            print(report)
        
        logger.info("Git repository analysis completed successfully")
        
    except Exception as e:
        logger.error(f"Analysis failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
