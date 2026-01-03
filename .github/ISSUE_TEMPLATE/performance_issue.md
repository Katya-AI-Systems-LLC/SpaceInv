# GitHub Issue Templates for Space Invaders Enhanced Edition

---
name: Performance Issue
about: Report performance problems or optimization opportunities
title: "[PERFORMANCE]: "
labels: ["performance", "status/new"]
assignees: ""
projects: ""
milestone: ""

---

## 🚀 Performance Issue Report

### 📊 Performance Metrics
- **Platform**: [Web/Windows/Android/iOS]
- **Device**: [Device specifications]
- **Flutter Version**: [e.g. 3.16.0]
- **Browser**: [Chrome/Firefox/Safari/Edge/Other]
- **OS Version**: [Operating system version]

### 🎯 Performance Problem
What specific performance issue are you experiencing?

- [ ] **Low FPS** - Frame rate drops below 60 FPS
- [ ] **Long Load Times** - Application takes too long to load
- [ ] **Memory Leaks** - Memory usage increases over time
- [ ] **High CPU Usage** - CPU usage is consistently high
- [ ] **Network Latency** - Slow network responses
- [ ] **UI Lag** - User interface is unresponsive
- [ ] **Battery Drain** - Excessive battery consumption
- [ ] **Storage Issues** - High storage usage or slow I/O
- [ ] **Other**: [Specify]

### 📈 Performance Data
Please provide specific performance measurements:

#### Before Issue
- **FPS**: [e.g., 45 FPS]
- **Load Time**: [e.g., 3.5 seconds]
- **Memory Usage**: [e.g., 250 MB]
- **CPU Usage**: [e.g., 75%]
- **Battery Impact**: [e.g., High]

#### Expected Performance
- **FPS**: [e.g., 60 FPS]
- **Load Time**: [e.g., 1.5 seconds]
- **Memory Usage**: [e.g., 150 MB]
- **CPU Usage**: [e.g., 25%]
- **Battery Impact**: [e.g., Low]

### 🔄 Reproduction Steps
Steps to reproduce the performance issue:
1. 
2. 
3. 
4. 

### 🎮 Game Context
When does the performance issue occur?

- [ ] **During Gameplay** - While actively playing
- [ ] **During Menu Navigation** - While navigating menus
- [ ] **During Loading Screens** - While loading game content
- [ ] **During Cutscenes** - During story sequences
- [ ] **During Multiplayer** - During online play
- [ ] **During Specific Game Modes** - [Specify which mode]
- [ ] **Continuous** - Issue persists throughout gameplay
- [ ] **Intermittent** - Issue occurs sporadically

### 📱 Platform-Specific Details

#### Web Performance
- [ ] **Canvas Rendering Issues** - Canvas performance problems
- [ ] **JavaScript Performance** - JS execution bottlenecks
- [ ] **Asset Loading** - Slow asset loading
- [ ] **WebGL Performance** - WebGL rendering issues
- [ ] **Browser Compatibility** - Browser-specific performance

#### Mobile Performance
- [ ] **Thermal Throttling** - Device overheating
- [ ] **Battery Optimization** - Battery saving mode impact
- [ ] **Background Processing** - Background task performance
- [ ] **Touch Response** - Touch input latency
- [ ] **Screen Rotation** - Performance during orientation changes

#### Desktop Performance
- [ ] **GPU Acceleration** - Hardware acceleration issues
- [ ] **Window Management** - Window resizing/moving performance
- [ ] **Multi-monitor** - Multi-monitor setup performance
- [ ] **System Resources** - System resource conflicts
- [ ] **Driver Issues** - Graphics driver problems

### 🧪 Performance Testing
Have you performed any performance testing?

- [ ] **FPS Monitoring** - Measured frame rate
- [ ] **Memory Profiling** - Analyzed memory usage
- [ ] **CPU Profiling** - Analyzed CPU usage
- [ ] **Network Analysis** - Measured network performance
- [ ] **Battery Testing** - Measured battery consumption
- [ ] **Benchmark Testing** - Ran performance benchmarks

### 📊 Profiling Data
Please attach any profiling data or screenshots:

#### Performance Screenshots
- [ ] **FPS Graph** - Frame rate over time
- [ ] **Memory Graph** - Memory usage over time
- [ ] **CPU Graph** - CPU usage over time
- [ ] **Network Graph** - Network activity over time
- [ ] **Battery Graph** - Battery consumption over time

#### Performance Logs
- [ ] **Flutter Logs** - Flutter performance logs
- [ ] **Browser DevTools** - Browser performance data
- [ ] **System Logs** - Operating system logs
- [ ] **GPU Logs** - Graphics driver logs

### 🔍 Root Cause Analysis
What do you think might be causing the performance issue?

#### Potential Causes
- [ ] **Inefficient Code** - Poorly optimized algorithms
- [ ] **Memory Leaks** - Unreleased memory
- [ ] **Excessive Rendering** - Too many draw calls
- [ ] **Large Assets** - Oversized textures/models
- [ ] **Network Bottlenecks** - Slow network operations
- [ ] **Third-Party Libraries** - External library issues
- [ ] **Platform Limitations** - Hardware/software limitations
- [ ] **Configuration Issues** - Incorrect settings

#### Recent Changes
- [ ] **Code Changes** - Recent code modifications
- [ ] **Asset Updates** - New or modified assets
- [ ] **Dependency Updates** - Updated libraries
- [ ] **Configuration Changes** - Modified settings
- [ ] **Platform Updates** - OS/browser updates

### 🎯 Impact Assessment
How does this performance issue affect the user experience?

#### User Experience Impact
- [ ] **Gameplay Disruption** - Makes game unplayable
- [ ] **Frustration** - Causes user frustration
- [ ] **Accessibility Issues** - Affects accessibility
- [ ] **Competitive Disadvantage** - Affects multiplayer fairness
- [ ] **Device Compatibility** - Prevents use on certain devices
- [ ] **Battery Life** - Reduces device battery life

#### Business Impact
- [ ] **User Retention** - May cause users to quit
- [ ] **Reviews** - May lead to negative reviews
- [ ] **Downloads** - May affect download numbers
- [ ] **Revenue** - May impact monetization
- [ ] **Brand Reputation** - May damage brand image

### 🛠️ Suggested Solutions
What solutions have you tried or suggest?

#### Workarounds
- [ ] **Lower Graphics Settings** - Reduced visual quality
- [ ] **Close Background Apps** - Closed other applications
- [ ] **Restart Application** - Restarted the game
- [ ] **Clear Cache** - Cleared application cache
- [ ] **Update Drivers** - Updated graphics drivers
- [ ] **Change Browser** - Used different browser

#### Proposed Fixes
- [ ] **Code Optimization** - Optimize algorithms
- [ ] **Asset Optimization** - Compress/optimize assets
- [ ] **Caching Improvements** - Better caching strategy
- [ ] **Lazy Loading** - Load assets on demand
- [ ] **Memory Management** - Improve memory handling
- [ ] **GPU Optimization** - Better GPU utilization

### 📋 Testing Requirements
What testing should be performed to verify the fix?

#### Performance Testing
- [ ] **Benchmark Testing** - Run performance benchmarks
- [ ] **Stress Testing** - Test under heavy load
- [ ] **Long-term Testing** - Test over extended periods
- [ ] **Multi-device Testing** - Test on various devices
- [ ] **Cross-platform Testing** - Test on all platforms

#### Regression Testing
- [ ] **Functionality Testing** - Ensure features still work
- [ ] **Compatibility Testing** - Test device compatibility
- [ ] **Accessibility Testing** - Test accessibility features
- [ ] **Security Testing** - Ensure security is maintained

### 🎯 Acceptance Criteria
What defines successful resolution of this performance issue?

#### Performance Targets
- [ ] **FPS Target** - Achieve 60+ FPS consistently
- [ ] **Load Time Target** - Load within 2 seconds
- [ ] **Memory Target** - Use less than 200 MB
- [ ] **CPU Target** - Use less than 30% CPU
- [ ] **Battery Target** - Minimal battery impact

#### Quality Targets
- [ ] **Stability** - No crashes or freezes
- [ ] **Consistency** - Performance is consistent
- [ ] **Scalability** - Performance scales with load
- [ ] **Maintainability** - Code is maintainable

### 🔗 Related Issues
- **Related Issue**: #[issue number]
- **Duplicate of**: #[issue number]
- **Blocks**: #[issue number]
- **Caused by**: #[issue number]

### 📅 Timeline
When should this performance issue be addressed?

- [ ] **Critical** - Fix immediately (within 24 hours)
- [ ] **High** - Fix soon (within 1 week)
- [ ] **Medium** - Fix in next release (within 1 month)
- [ ] **Low** - Fix when convenient (in future release)

### ✅ Checklist
- [ ] I have provided specific performance metrics
- [ ] I have included reproduction steps
- [ ] I have attached profiling data/screenshots
- [ ] I have identified potential causes
- [ ] I have assessed the impact
- [ ] I have suggested solutions
- [ ] I have defined acceptance criteria
- [ ] I have searched for similar issues

---

**🚀 Thank you for helping us improve Space Invaders Enhanced Edition performance!**
