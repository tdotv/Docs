package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"os/exec"
	"strconv"
	"strings"
	_ "syscall"
	"time"
)

func isRunning(procName string) (bool, error) {
	out, err := exec.Command("tasklist", "/FI", "IMAGENAME eq "+procName).CombinedOutput()
	if err != nil {
		return false, fmt.Errorf("tasklist failed: %w", err)
	}
	s := string(out)

	return strings.Contains(s, procName), nil
}

func startProcess(path string, args []string, wd string) error {
	cmd := exec.Command(path, args...)
	if wd != "" {
		cmd.Dir = wd
	}

	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Start(); err != nil {
		return fmt.Errorf("failed to start: %w", err)
	}
	fmt.Println("... PID=", cmd.Process.Pid)

	return nil
}

func killProcess(procName string) error {
	out, err := exec.Command("taskkill", "/IM", procName, "/F").CombinedOutput()
	if err != nil {
		return fmt.Errorf("taskkill failed: %w; output: %s", err, string(out))
	}
	return nil
}

func getCPUPercent() (float64, error) {
	out, err := exec.Command("wmic", "cpu", "get", "loadpercentage", "/value").CombinedOutput()
	if err != nil {
		return 0, fmt.Errorf("wmic failed: %w", err)
	}
	s := string(out)

	lines := strings.Split(s, "\n")
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if strings.HasPrefix(line, "LoadPercentage=") {
			val := strings.TrimPrefix(line, "LoadPercentage=")
			val = strings.TrimSpace(val)
			if val == "" {
				continue
			}
			i, err := strconv.Atoi(val)
			if err != nil {
				return 0, fmt.Errorf("parse int failed: %w (val=%q)", err, val)
			}
			return float64(i), nil
		}
	}
	return 0, fmt.Errorf("couldn't parse wmic output: %q", s)
}

// kill -> sleep -> start.
func monitorCPU(procName, exePath string, exeArgs []string, wd string, sampleInterval time.Duration, threshold float64, duration time.Duration, restartDelay time.Duration) {
	var aboveStart time.Time

	ticker := time.NewTicker(sampleInterval)
	defer ticker.Stop()

	for now := range ticker.C {
		cpu, err := getCPUPercent()
		if err != nil {
			log.Printf("monitorCPU: cannot get cpu percent: %v", err)
			// при ошибке просто продолжаем — не сбрасываем aboveStart, т.к. возможно временная ошибка
			continue
		}
		log.Printf("monitorCPU: cpu=%.0f%%", cpu)

		if cpu > threshold {
			if aboveStart.IsZero() {
				aboveStart = now
				log.Printf("monitorCPU: CPU выше %.0f%% — начали считать время (с %s)", threshold, aboveStart.Format(time.RFC3339))
			} else {
				elapsed := now.Sub(aboveStart)
				log.Printf("monitorCPU: CPU > %.0f%% for %s (needs %s to restart)", threshold, elapsed.Round(time.Second), duration)
				if elapsed >= duration {
					log.Printf("monitorCPU: CPU > %.0f%% for %s — restart %s", threshold, duration, procName)

					if err := killProcess(procName); err != nil {
						log.Printf("monitorCPU: Failed to kill %s: %v", procName, err)
					} else {
						log.Printf("monitorCPU: Process %s is killed", procName)
					}

					time.Sleep(2 * time.Second)

					if err := startProcess(exePath, exeArgs, wd); err != nil {
						log.Printf("monitorCPU: failed to start %s: %v", exePath, err)
					} else {
						log.Printf("monitorCPU: Process %s is restarted", procName)
					}

					time.Sleep(restartDelay)

					aboveStart = time.Time{}
				}
			}
		} else {
			if !aboveStart.IsZero() {
				log.Printf("monitorCPU: CPU < %.0f%% — reset (- %s)", threshold, now.Sub(aboveStart).Round(time.Second))
			}
			aboveStart = time.Time{}
		}
	}
}

func main() {
	exePath := flag.String("exe", "C:\\Users\\Администратор\\Desktop\\converter\\converter\\converterService.exe", "Full path to the executable to start")
	procName := flag.String("name", "converterService.exe", "Process image name to watch")
	checkInterval := flag.Duration("check", 5*time.Second, "How often to check whether the process is running")
	restartDelay := flag.Duration("restart-delay", 10*time.Second, "Delay after a restart attempt (prevents rapid restart loops)")
	logFile := flag.String("log", "", "Optional log file path (appends). If empty, logs to stdout")
	argsStr := flag.String("args", "", "Optional arguments for the executable (space-separated)")

	flag.Parse()

	if *logFile != "" {
		f, err := os.OpenFile(*logFile, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
		if err != nil {
			log.Fatalf("cannot open log file: %v", err)
		}
		defer f.Close()
		log.SetOutput(f)
	}
	log.Printf("monitor started: watching %s (will start %s if missing)", *procName, *exePath)
	if *argsStr != "" {
		log.Printf("start args: %s", *argsStr)
	}

	var exeArgs []string
	if *argsStr != "" {
		exeArgs = strings.Fields(*argsStr)
	}

	wd := ""
	if strings.Contains(*exePath, "\\") {
		wd = (*exePath)[:strings.LastIndex(*exePath, "\\")]
	}

	go monitorCPU(*procName, *exePath, exeArgs, wd, *checkInterval, 80.0, 5*time.Minute, *restartDelay)

	for {
		running, err := isRunning(*procName)
		if err != nil {
			log.Printf("Ошибка при проверке процесса: %v", err)
		} else if !running {
			log.Printf("Процесс %s не найден — пытаюсь запустить %s", *procName, *exePath)
			if err := startProcess(*exePath, exeArgs, wd); err != nil {
				log.Printf("Ошибка при запуске %s: %v", *exePath, err)
			} else {
				log.Printf("Команда запуска %s выполнена.", *exePath)
			}
			time.Sleep(*restartDelay)
		}
		time.Sleep(*checkInterval)
	}
}
