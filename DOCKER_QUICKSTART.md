# 🐳 Docker Quick Start - ATP Tour ETL

Instrucciones rápidas para ejecutar el proyecto en Docker.

## 🚀 Inicio Rápido (3 pasos)

### 1. Construir la imagen

```bash
docker build -t atp-tour-etl:latest .
```

### 2. Ejecutar con Streamlit

```bash
# Linux/macOS/Git Bash
docker run --rm -p 8501:8501 -v $(pwd)/outputs:/app/outputs atp-tour-etl:latest

# Windows PowerShell
docker run --rm -p 8501:8501 -v ${PWD}/outputs:/app/outputs atp-tour-etl:latest
```

### 3. Abrir navegador

Visita: **http://localhost:8501**

---

## 📋 Opciones Alternativas

### Opción A: Scripts automatizados

```bash
# Linux/macOS
./run-docker.sh

# Windows PowerShell
.\run-docker.ps1
```

### Opción B: Docker Compose

```bash
# Iniciar
docker-compose up

# Iniciar en background
docker-compose up -d

# Ver logs
docker-compose logs -f

# Detener
docker-compose down
```

### Opción C: Solo análisis (sin web)

```bash
docker run --rm -v $(pwd)/outputs:/app/outputs atp-tour-etl:latest python analysis/analysis.py
```

---

## 📁 Archivos Generados

- `outputs/matches_per_year_surface.png` - Gráfico de partidos por año y superficie
- `outputs/top10_winners.png` - Top 10 jugadores por victorias
- `Extract/*.csv` - Datos limpios (si usas la funcionalidad de limpieza)
- `Load/*.db` - Bases de datos SQLite (si usas la carga a BD)

---

## 📚 Documentación Completa

- **[DOCKER_INSTRUCTIONS.md](DOCKER_INSTRUCTIONS.md)** - Guía detallada de uso
- **[DOCKER_SECURITY.md](DOCKER_SECURITY.md)** - Mejores prácticas de seguridad

---

## 🆘 Ayuda Rápida

```bash
# Ver contenedores corriendo
docker ps

# Ver logs
docker logs <container_id>

# Detener todo
docker stop $(docker ps -q)

# Limpiar todo
docker system prune -a
```

---

**¡Listo para analizar datos ATP! 🎾📊**
