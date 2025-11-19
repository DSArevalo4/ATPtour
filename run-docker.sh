#!/bin/bash
# 🐳 Script de Ejecución - Docker ATP Tour ETL Pipeline (Linux/macOS)
# Ejecuta el contenedor y gestiona todos los archivos generados

set -e

echo ""
echo "🎾 Ejecutando Pipeline ETL ATP Tour en Docker..."
echo ""

# Verificar que Docker está corriendo
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker no está corriendo. Por favor, inícialo primero."
    echo ""
    exit 1
fi

# Verificar que la imagen existe
if ! docker images -q atp-tour-etl:latest >/dev/null 2>&1 || [ -z "$(docker images -q atp-tour-etl:latest)" ]; then
    echo "⚠️  Imagen 'atp-tour-etl:latest' no encontrada. Construyendo..."
    echo ""
    docker build -t atp-tour-etl:latest .
    if [ $? -ne 0 ]; then
        echo ""
        echo "❌ Error al construir la imagen Docker"
        echo ""
        exit 1
    fi
fi

# Crear directorios si no existen
for dir in outputs Extract Load; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo "✅ Directorio creado: $dir"
    fi
done

echo ""
echo "🚀 Iniciando contenedor..."
echo ""

# Preguntar modo de ejecución
read -p "¿Ejecutar en modo análisis (A) o Streamlit web (W)? [A/W]: " mode

if [ "$mode" = "A" ] || [ "$mode" = "a" ]; then
    # Modo análisis batch
    echo ""
    echo "📊 Ejecutando análisis de datos ATP..."
    echo ""
    
    docker run --rm \
        -v "$(pwd)/outputs:/app/outputs" \
        atp-tour-etl:latest \
        python -u analysis/analysis.py
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Análisis completado exitosamente!"
        echo ""
        
        echo "📁 Archivos generados en ./outputs/:"
        ls -lh outputs/ | grep -v "^total" | grep -v "^d"
        
        echo ""
        echo "🖼️  Gráficas disponibles:"
        echo "  - outputs/matches_per_year_surface.png"
        echo "  - outputs/top10_winners.png"
        echo ""
        
        read -p "¿Deseas abrir las gráficas? (S/N): " open
        if [ "$open" = "S" ] || [ "$open" = "s" ]; then
            if [ -f "outputs/matches_per_year_surface.png" ]; then
                if command -v xdg-open &> /dev/null; then
                    xdg-open "outputs/matches_per_year_surface.png" &
                elif command -v open &> /dev/null; then
                    open "outputs/matches_per_year_surface.png"
                fi
            fi
            if [ -f "outputs/top10_winners.png" ]; then
                if command -v xdg-open &> /dev/null; then
                    xdg-open "outputs/top10_winners.png" &
                elif command -v open &> /dev/null; then
                    open "outputs/top10_winners.png"
                fi
            fi
        fi
    else
        echo ""
        echo "❌ Error al ejecutar el análisis"
        echo ""
        exit 1
    fi
    
else
    # Modo Streamlit web
    echo ""
    echo "🌐 Iniciando aplicación Streamlit..."
    echo ""
    echo "📍 La aplicación estará disponible en: http://localhost:8501"
    echo ""
    echo "⏹️  Presiona Ctrl+C para detener el servidor"
    echo ""
    
    docker run --rm \
        -p 8501:8501 \
        -v "$(pwd)/outputs:/app/outputs" \
        -v "$(pwd)/Extract:/app/Extract" \
        -v "$(pwd)/Load:/app/Load" \
        atp-tour-etl:latest
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Servidor Streamlit detenido correctamente"
        echo ""
    else
        echo ""
        echo "⚠️  Servidor Streamlit cerrado (esto es normal)"
        echo ""
    fi
fi

echo ""
echo "✨ Ejecución finalizada!"
echo ""
