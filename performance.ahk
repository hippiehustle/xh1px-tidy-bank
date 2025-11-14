#Requires AutoHotkey v2.0

; ==========================================
; PERFORMANCE MONITORING SYSTEM
; Tracks bot performance metrics and runtime statistics
; ==========================================

class PerformanceMonitor {
    static metrics := Map()
    static sessionStart := A_TickCount
    static operationTimers := Map()

    ; Initialize performance tracking
    static Initialize() {
        this.metrics := Map(
            "operations_completed", 0,
            "items_sorted", 0,
            "tabs_switched", 0,
            "errors_encountered", 0,
            "drags_performed", 0,
            "screenshots_taken", 0,
            "total_runtime_ms", 0
        )
        this.sessionStart := A_TickCount
        this.operationTimers := Map()
    }

    ; Start timing an operation
    static StartTimer(operationName) {
        this.operationTimers[operationName] := A_TickCount
    }

    ; Stop timing an operation and record the duration
    static StopTimer(operationName) {
        if !this.operationTimers.Has(operationName) {
            return 0
        }

        startTime := this.operationTimers[operationName]
        duration := A_TickCount - startTime
        this.operationTimers.Delete(operationName)

        return duration
    }

    ; Record a metric
    static RecordMetric(metricName, value := 1) {
        if this.metrics.Has(metricName) {
            this.metrics[metricName] += value
        } else {
            this.metrics[metricName] := value
        }
    }

    ; Get a metric value
    static GetMetric(metricName) {
        return this.metrics.Has(metricName) ? this.metrics[metricName] : 0
    }

    ; Get all metrics
    static GetAllMetrics() {
        return this.metrics.Clone()
    }

    ; Get session elapsed time in milliseconds
    static GetElapsedTime() {
        return A_TickCount - this.sessionStart
    }

    ; Get session elapsed time formatted as string
    static GetElapsedTimeFormatted() {
        totalMs := this.GetElapsedTime()
        hours := Floor(totalMs / 3600000)
        minutes := Floor((totalMs mod 3600000) / 60000)
        seconds := Floor((totalMs mod 60000) / 1000)

        if (hours > 0) {
            return hours . "h " . minutes . "m " . seconds . "s"
        } else if (minutes > 0) {
            return minutes . "m " . seconds . "s"
        } else {
            return seconds . "s"
        }
    }

    ; Calculate average time per operation
    static GetAverageOperationTime(operationName, totalCount) {
        if (totalCount == 0) {
            return 0
        }

        metricName := operationName . "_total_ms"
        totalTime := this.GetMetric(metricName)
        return Round(totalTime / totalCount, 2)
    }

    ; Get performance summary
    static GetPerformanceSummary() {
        summary := "=== PERFORMANCE SUMMARY ===`n"
        summary .= "Session Duration: " . this.GetElapsedTimeFormatted() . "`n"
        summary .= "Operations Completed: " . this.GetMetric("operations_completed") . "`n"
        summary .= "Items Sorted: " . this.GetMetric("items_sorted") . "`n"
        summary .= "Tabs Switched: " . this.GetMetric("tabs_switched") . "`n"
        summary .= "Drags Performed: " . this.GetMetric("drags_performed") . "`n"
        summary .= "Screenshots Taken: " . this.GetMetric("screenshots_taken") . "`n"
        summary .= "Errors Encountered: " . this.GetMetric("errors_encountered") . "`n"

        ; Calculate efficiency metrics
        operationsCompleted := this.GetMetric("operations_completed")
        if (operationsCompleted > 0) {
            errors := this.GetMetric("errors_encountered")
            errorRate := Round((errors / operationsCompleted) * 100, 2)
            summary .= "Error Rate: " . errorRate . "%`n"
        }

        return summary
    }

    ; Reset all metrics
    static Reset() {
        this.Initialize()
    }

    ; Log current metrics to a file
    static LogMetricsToFile(logFile) {
        try {
            metricsReport := this.GetPerformanceSummary()
            timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")

            logEntry := "`n=== Metrics Report at " . timestamp . " ===`n"
            logEntry .= metricsReport . "`n"

            FileAppend(logEntry, logFile)
            return true
        } catch as err {
            return false
        }
    }
}

; ==========================================
; OPERATION TRACKING HELPER
; Convenient class for tracking individual operations
; ==========================================

class OperationTracker {
    __New(operationName) {
        this.name := operationName
        this.startTime := A_TickCount
    }

    ; Complete the operation and record metrics
    Complete(success := true) {
        duration := A_TickCount - this.startTime

        if (success) {
            PerformanceMonitor.RecordMetric("operations_completed")
        } else {
            PerformanceMonitor.RecordMetric("errors_encountered")
        }

        ; Record operation-specific duration
        metricName := this.name . "_ms"
        PerformanceMonitor.RecordMetric(metricName, duration)

        return duration
    }

    ; Get operation duration without completing
    GetDuration() {
        return A_TickCount - this.startTime
    }
}

; ==========================================
; RESOURCE USAGE TRACKER
; Tracks system resource usage during bot operation
; ==========================================

class ResourceTracker {
    static maxMemoryUsage := 0
    static recordedMetrics := Map()

    ; Record current memory usage
    static RecordMemoryUsage() {
        ; AutoHotkey doesn't have direct memory reporting in v2.0
        ; This is a placeholder for potential future implementation
        ; In production, you might use WMI or external tools
        return true
    }

    ; Record CPU usage
    static RecordCPUUsage() {
        ; CPU tracking would require WMI queries
        ; This is a placeholder for future implementation
        return true
    }

    ; Get resource usage report
    static GetResourceReport() {
        report := "=== RESOURCE USAGE ===`n"
        report .= "Peak Memory Usage: " . this.maxMemoryUsage . " MB (estimated)`n"
        report .= "Note: Detailed resource tracking requires system tools`n"
        return report
    }
}

; ==========================================
; PERFORMANCE UTILITY FUNCTIONS
; ==========================================

; Create a performance-tracked operation
CreateTrackedOperation(operationName) {
    return OperationTracker(operationName)
}

; Log performance metrics (intended to be called periodically)
LogPerformanceMetrics(logFile := FilePathConstants.LOG_FILE) {
    PerformanceMonitor.LogMetricsToFile(logFile)
}

; Get current performance summary
GetPerformanceSummary() {
    return PerformanceMonitor.GetPerformanceSummary()
}
