# 🐳 Script de Ejecución - Docker ATP Tour ETL Pipeline
# Ejecuta el contenedor y gestiona todos los archivos generados

Write-Host "`n🎾 Ejecutando Pipeline ETL ATP Tour en Docker...`n" -ForegroundColor Cyan

# Verificar que Docker está corriendo
$dockerRunning = docker info 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker Desktop no está corriendo. Por favor, inícialo primero.`n" -ForegroundColor Red
    exit 1
}

# Verificar que la imagen existe
$imageExists = docker images -q atp-tour-etl:latest
if (-not $imageExists) {
    Write-Host "⚠️  Imagen 'atp-tour-etl:latest' no encontrada. Construyendo...`n" -ForegroundColor Yellow
    docker build -t atp-tour-etl:latest .
    if ($LASTEXITCODE -ne 0) {
        Write-Host "`n❌ Error al construir la imagen Docker`n" -ForegroundColor Red
        exit 1
    }
}

# Crear directorios si no existen
$directories = @("outputs", "Extract", "Load")
foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir | Out-Null
        Write-Host "✅ Directorio creado: $dir" -ForegroundColor Green
    }
}

Write-Host "`n🚀 Iniciando contenedor...`n" -ForegroundColor Cyan

# Opción 1: Solo ejecutar análisis (sin Streamlit)
$mode = Read-Host "¿Ejecutar en modo análisis (A) o Streamlit web (W)? [A/W]"

if ($mode -eq "A" -or $mode -eq "a") {
    # Modo análisis batch
    Write-Host "`n📊 Ejecutando análisis de datos ATP...`n" -ForegroundColor Cyan
    
    docker run --rm `
        -v ${PWD}/outputs:/app/outputs `
        atp-tour-etl:latest `
        python -u analysis/analysis.py
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ Análisis completado exitosamente!`n" -ForegroundColor Green
        
        Write-Host "📁 Archivos generados en ./outputs/:" -ForegroundColor Cyan
        Get-ChildItem -Path .\outputs\ -File | 
            Where-Object { $_.Name -ne ".gitkeep" } |
            Select-Object Name, @{N='Tamaño(KB)';E={[math]::Round($_.Length/1KB,2)}} |
            Format-Table -AutoSize
        
        Write-Host "`n🖼️  Gráficas disponibles:" -ForegroundColor Cyan
        Write-Host "  - outputs/matches_per_year_surface.png" -ForegroundColor White
        Write-Host "  - outputs/top10_winners.png`n" -ForegroundColor White
        
        $open = Read-Host "¿Deseas abrir las gráficas? (S/N)"
        if ($open -eq "S" -or $open -eq "s") {
            if (Test-Path "outputs/matches_per_year_surface.png") {
                Start-Process "outputs/matches_per_year_surface.png"
            }
            if (Test-Path "outputs/top10_winners.png") {
                Start-Process "outputs/top10_winners.png"
            }
        }
    } else {
        Write-Host "`n❌ Error al ejecutar el análisis`n" -ForegroundColor Red
        exit 1
    }
    
} else {
    # Modo Streamlit web
    Write-Host "`n🌐 Iniciando aplicación Streamlit...`n" -ForegroundColor Cyan
    Write-Host "📍 La aplicación estará disponible en: http://localhost:8501`n" -ForegroundColor Yellow
    Write-Host "⏹️  Presiona Ctrl+C para detener el servidor`n" -ForegroundColor Gray
    
    docker run --rm `
        -p 8501:8501 `
        -v ${PWD}/outputs:/app/outputs `
        -v ${PWD}/Extract:/app/Extract `
        -v ${PWD}/Load:/app/Load `
        atp-tour-etl:latest
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ Servidor Streamlit detenido correctamente`n" -ForegroundColor Green
    } else {
        Write-Host "`n⚠️  Servidor Streamlit cerrado (esto es normal)`n" -ForegroundColor Yellow
    }
}

Write-Host "`n✨ Ejecución finalizada!`n" -ForegroundColor Green
