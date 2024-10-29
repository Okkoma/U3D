@echo off

powershell -Command "Start-Process PowerShell -ArgumentList '-ExecutionPolicy Bypass -File ""%~dp0install.ps1""' -Verb RunAs"

