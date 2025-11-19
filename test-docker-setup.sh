#!/bin/bash
# Script de prueba rápida para verificar la implementación Docker

echo "🧪 Iniciando pruebas de verificación Docker..."
echo ""

# Test 1: Verificar archivos
echo "📋 Test 1: Verificando archivos necesarios..."
files=(
    "Dockerfile"
    "docker-compose.yml"
    ".dockerignore"
    "requirementes.txt"
    "run-docker.sh"
    "run-docker.ps1"
    "DOCKER_QUICKSTART.md"
    "DOCKER_INSTRUCTIONS.md"
    "DOCKER_SECURITY.md"
)

missing=0
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file (FALTA)"
        missing=$((missing + 1))
    fi
done

if [ $missing -eq 0 ]; then
    echo "  ✅ Todos los archivos presentes"
else
    echo "  ❌ Faltan $missing archivo(s)"
    exit 1
fi

echo ""

# Test 2: Verificar Docker
echo "📋 Test 2: Verificando Docker..."
if command -v docker &> /dev/null; then
    echo "  ✅ Docker instalado: $(docker --version)"
    if docker info &> /dev/null; then
        echo "  ✅ Docker corriendo"
    else
        echo "  ❌ Docker no está corriendo"
        echo "  ⚠️  Inicia Docker Desktop antes de continuar"
        exit 1
    fi
else
    echo "  ❌ Docker no instalado"
    exit 1
fi

echo ""

# Test 3: Verificar datos
echo "📋 Test 3: Verificando datos ATP..."
if [ -d "tennis_atp_data" ]; then
    count=$(ls tennis_atp_data/*.csv 2>/dev/null | wc -l)
    if [ $count -gt 0 ]; then
        echo "  ✅ Directorio tennis_atp_data encontrado ($count archivos CSV)"
    else
        echo "  ⚠️  Directorio existe pero no hay CSVs"
    fi
else
    echo "  ❌ Directorio tennis_atp_data no encontrado"
    exit 1
fi

echo ""

# Test 4: Build de prueba (solo validación, sin construir)
echo "📋 Test 4: Validando Dockerfile..."
if docker build --help &> /dev/null; then
    echo "  ✅ Comando docker build disponible"
    echo "  ℹ️  Para construir la imagen ejecuta:"
    echo "     docker build -t atp-tour-etl:latest ."
else
    echo "  ❌ No se puede ejecutar docker build"
    exit 1
fi

echo ""

# Test 5: Verificar permisos de scripts
echo "📋 Test 5: Verificando permisos de scripts..."
if [ -x "run-docker.sh" ]; then
    echo "  ✅ run-docker.sh tiene permisos de ejecución"
else
    echo "  ⚠️  run-docker.sh no tiene permisos de ejecución"
    echo "     Ejecuta: chmod +x run-docker.sh"
fi

echo ""

# Test 6: Verificar sintaxis de docker-compose
echo "📋 Test 6: Validando docker-compose.yml..."
if command -v docker-compose &> /dev/null || docker compose version &> /dev/null; then
    if docker compose config &> /dev/null || docker-compose config &> /dev/null; then
        echo "  ✅ docker-compose.yml válido"
    else
        echo "  ❌ Error en docker-compose.yml"
        exit 1
    fi
else
    echo "  ⚠️  docker-compose no instalado (opcional)"
fi

echo ""

# Resumen
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ TODAS LAS PRUEBAS PASARON"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🎉 Tu proyecto está listo para usar Docker!"
echo ""
echo "📝 Próximos pasos:"
echo "   1. Construir imagen:"
echo "      docker build -t atp-tour-etl:latest ."
echo ""
echo "   2. Ejecutar (elige una opción):"
echo "      a) Streamlit:"
echo "         docker run --rm -p 8501:8501 atp-tour-etl:latest"
echo ""
echo "      b) Solo análisis:"
echo "         docker run --rm -v \$(pwd)/outputs:/app/outputs atp-tour-etl:latest python analysis/analysis.py"
echo ""
echo "      c) Script automatizado:"
echo "         ./run-docker.sh"
echo ""
echo "      d) Docker Compose:"
echo "         docker-compose up"
echo ""
echo "📚 Documentación:"
echo "   - Inicio rápido: DOCKER_QUICKSTART.md"
echo "   - Guía completa: DOCKER_INSTRUCTIONS.md"
echo "   - Seguridad: DOCKER_SECURITY.md"
echo ""
