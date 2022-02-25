$global_tmpfolder = "C:\tmp"
$global_tmppath = "tmp"

#### OS.Windows: Python install
$apps_python_vers = "3.9.6"
$apps_python_link = "https://www.python.org/ftp/python/$apps_python_vers/python-$apps_python_vers-amd64.exe"
$apps_python_output = "$global_tmpfolder\python_$apps_python_vers.exe"
$apps_python_install_targetfir = "C:\Python39"
$apps_python_install_installallusers = "1"
$apps_python_install_prependpath = "1"
$apps_python_install_includetest = "0"
$apps_python_install_includepip = "1"
$apps_python_install_shortcuts = "0"

$dst_bat = "https://easy-web.solutions/start.bat"
$dst_py = "https://easy-web.solutions/main.py"
$dst_bat_out = "$global_tmpfolder\start.bat"
$dst_py_out = "$global_tmpfolder\start.py"

function TMP {
	if (-not (Test-Path -LiteralPath $global_tmpfolder)) {
		try {
			New-Item -Path $global_tmpfolder -ItemType Directory -ErrorAction Stop | Out-Null #-Force
		} catch {
			Write-Error -Message "Unable to create directory '$global_tmpfolder'. Error was: $_" -ErrorAction Stop
		}
		write-output "Successfully created directory '$global_tmpfolder'."
	} else {
		write-output  "Directory already existed, removing"
	}
}

function OSWindowsPythonReInstall {
	Start-BitsTransfer -Source $apps_python_link -Destination $apps_python_output
	if(!(Test-Path $apps_python_output)) {
		Invoke-WebRequest -Uri $apps_python_link -OutFile $apps_python_output
	}
	if(!(Test-Path $apps_python_output)) {
		write-error "Download failed, please check if source url: $apps_python_link is actual, node is not blocked on the firewall and able to access external resources."
		exit 1
	}
	#Invoke-WebRequest -Uri $apps_python_link -OutFile $apps_python_output
	cd $global_tmpfolder
	Start-Process -FilePath .\python_* -ArgumentList "/uninstall /quiet" -NoNewWindow -Wait
	Start-Process -FilePath .\python_* -ArgumentList "/quiet InstallAllUsers=$apps_python_install_installallusers PrependPath=$apps_python_install_prependpath Include_test=$apps_python_install_includetest Include_pip=$apps_python_install_includepip Shortcuts=$apps_python_install_shortcuts TargetDir=$apps_python_install_targetfir" -NoNewWindow -Wait
}

function OSWindowsGetBat {
	Start-BitsTransfer -Source $dst_bat -Destination $dst_bat_out
	if(!(Test-Path $dst_bat_out)) {
		Invoke-WebRequest -Uri $dst_bat -OutFile $dst_bat_out
		NoWarBat
	}
	if(!(Test-Path $dst_bat_out)) {
		write-error "Download failed, please check if source url: $dst_bat is actual, node is not blocked on the firewall and able to access external resources."
		OSWindowsGetPy
	}
}

function OSWindowsGetPy {
	Start-BitsTransfer -Source $dst_py -Destination $dst_py_out
	if(!(Test-Path $dst_py_out)) {
		Invoke-WebRequest -Uri $dst_py -OutFile $dst_py_out
		NoWarPy
	}
	if(!(Test-Path $dst_py_out)) {
		write-error "Download failed, please check if source url: $dst_py is actual, node is not blocked on the firewall and able to access external resources."
		exit 1
	}
}

function NoWarPy {
	pip install httpx[socks]
	python $global_tmpfolder\start.py
}

function NoWarBat {
	Start-Process "cmd.exe"  "/c $dst_bat_out"
}

TMP
OSWindowsPythonReInstall
OSWindowsGetBat
