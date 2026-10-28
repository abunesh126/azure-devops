pipeline {
    agent any

    options {
        skipDefaultCheckout(true)
        disableConcurrentBuilds()
    }

    environment {
        RESOURCE_GROUP = 'devops-rg'
        APP_SERVICE_NAME = 'azure-devops-abunesh-2026'
        EXPECTED_MARKER = 'DEPLOYMENT-V1'
        EXPECTED_TITLE = 'Automated Web Application Deployment on Microsoft Azure'
        PATH = "C:\\terraform;C:\\Program Files\\Microsoft SDKs\\Azure\\CLI2\\wbin;${env.PATH}"
    }

    stages {
        stage('Checkout') {
            steps {
                deleteDir()
                checkout scm
                script {
                    env.COMMIT_SHA = bat(
                        script: '@git rev-parse HEAD',
                        returnStdout: true
                    ).trim()
                }
                bat 'if not exist app\\index.html exit /b 1'
            }
        }

        stage('Validate') {
            steps {
                bat '''
                    findstr /C:"Automated Web Application Deployment on Microsoft Azure" app\\index.html >nul
                    if errorlevel 1 exit /b 1
                    findstr /C:"DEPLOYMENT-V1" app\\index.html >nul
                    if errorlevel 1 exit /b 1
                    terraform -chdir=terraform init -backend=false -input=false
                    if errorlevel 1 exit /b 1
                    terraform -chdir=terraform fmt -check
                    terraform -chdir=terraform validate
                '''
            }
        }

        stage('Build') {
            steps {
                bat '''
                    if exist website.zip del /f /q website.zip
                    powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; Compress-Archive -Path 'app\\*' -DestinationPath 'website.zip' -Force"
                    powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $p=Join-Path $env:TEMP ('website-' + [guid]::NewGuid()); try { Expand-Archive website.zip $p; if (-not (Test-Path (Join-Path $p 'index.html'))) { throw 'index.html is not at ZIP root' } } finally { if (Test-Path $p) { Remove-Item $p -Recurse -Force } }"
                '''
            }
        }

        stage('Infrastructure Validation') {
            steps {
                bat 'where az'
                bat 'az account show --output none'
                bat 'az group show --name "%RESOURCE_GROUP%" --output none'
                bat 'az webapp show --resource-group "%RESOURCE_GROUP%" --name "%APP_SERVICE_NAME%" --output none'
            }
        }

        stage('Deploy') {
            steps {
                withCredentials([
                    string(credentialsId: 'AZURE_CLIENT_ID', variable: 'AZURE_CLIENT_ID'),
                    string(credentialsId: 'AZURE_CLIENT_SECRET', variable: 'AZURE_CLIENT_SECRET'),
                    string(credentialsId: 'AZURE_TENANT_ID', variable: 'AZURE_TENANT_ID'),
                    string(credentialsId: 'AZURE_SUBSCRIPTION_ID', variable: 'AZURE_SUBSCRIPTION_ID')
                ]) {
                    bat '''
                        @echo off
                        setlocal
                        set "AZURE_CONFIG_DIR=%WORKSPACE%\\.azure"
                        az login --service-principal --username "%AZURE_CLIENT_ID%" --password "%AZURE_CLIENT_SECRET%" --tenant "%AZURE_TENANT_ID%" --output none
                        if errorlevel 1 exit /b 1
                        az account set --subscription "%AZURE_SUBSCRIPTION_ID%"
                        if errorlevel 1 exit /b 1
                        az webapp deploy --resource-group "%RESOURCE_GROUP%" --name "%APP_SERVICE_NAME%" --src-path website.zip --type zip --output none
                    '''
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                powershell '''
                    $ErrorActionPreference = 'Stop'
                    $url = "https://$env:APP_SERVICE_NAME.azurewebsites.net/?v=$([DateTimeOffset]::UtcNow.ToUnixTimeSeconds())"
                    $found = $false
                    for ($attempt = 1; $attempt -le 5; $attempt++) {
                        try {
                            $response = Invoke-WebRequest -UseBasicParsing -Uri $url
                            if ($response.StatusCode -eq 200 -and $response.Content.Contains($env:EXPECTED_TITLE) -and $response.Content.Contains($env:EXPECTED_MARKER)) {
                                $found = $true
                                break
                            }
                        } catch {
                            if ($attempt -eq 5) { throw }
                        }
                        Start-Sleep -Seconds 10
                    }
                    if (-not $found) { throw "Live site did not contain the expected title and marker." }
                    Write-Host "Verified $env:EXPECTED_MARKER at $url"
                '''
            }
        }
    }

    post {
        always {
            bat 'if exist "%WORKSPACE%\\.azure" rmdir /s /q "%WORKSPACE%\\.azure"'
            archiveArtifacts artifacts: 'website.zip', fingerprint: true, allowEmptyArchive: true
        }
        success {
            echo "Deployment succeeded: ${env.COMMIT_SHA} -> ${env.APP_SERVICE_NAME} (${env.EXPECTED_MARKER})"
        }
    }
}
