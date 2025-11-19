# 🐳 Instrucciones de Docker - Pipeline ETL ATP Tour

Este documento explica cómo construir y ejecutar el contenedor Docker para el pipeline ETL de análisis de datos ATP Tour.

---

## 📋 Prerrequisitos

- **Docker Desktop** instalado ([Descargar aquí](https://www.docker.com/products/docker-desktop))
- **4 GB de RAM** mínimo disponible para Docker
- **2 GB de espacio en disco** libre
- Datos ATP Tour en la carpeta `tennis_atp_data/`

---

## 🏗️ Construcción del Contenedor

### Opción 1: Build Simple

```bash
# Navegar al directorio del proyecto
cd /workspaces/ATPtour

# Construir la imagen
docker build -t atp-tour-etl:latest .
```

### Opción 2: Build con etiqueta personalizada

```bash
docker build -t atp-tour-etl:v1.0 -t atp-tour-etl:latest .
```

### Opción 3: Build sin caché (para forzar reinstalación)

```bash
docker build --no-cache -t atp-tour-etl:latest .
```

**Tiempo estimado:** 3-5 minutos (primera vez)

---

## 🚀 Ejecución del Contenedor

### Opción 1: Ejecutar Solo el Análisis (sin Streamlit)

```bash
docker run --rm \
  -v $(pwd)/outputs:/app/outputs \
  atp-tour-etl:latest \
  python -u analysis/analysis.py
```

**Resultado:**
- ✅ Ejecuta el análisis de datos ATP
- ✅ Genera gráficas en `./outputs/`:
  - `matches_per_year_surface.png`
  - `top10_winners.png`
- ❌ No inicia interfaz web

---

### Opción 2: Ejecutar Streamlit Web App ⭐ RECOMENDADO

```bash
docker run --rm -p 8501:8501 \
  -v $(pwd)/outputs:/app/outputs \
  -v $(pwd)/tennis_atp_data:/app/tennis_atp_data \
  atp-tour-etl:latest
```

**Resultado:**
- ✅ Ejecuta el análisis completo
- ✅ Inicia Streamlit en http://localhost:8501
- ✅ Las gráficas persisten en `./outputs/`
- ✅ Puedes interactuar con la app desde el navegador

**Acceso:** Abre tu navegador en `http://localhost:8501`

---

### Opción 3: Ejecución con Persistencia Total

```bash
# Linux / macOS / Git Bash
docker run --rm -p 8501:8501 \
  -v $(pwd)/outputs:/app/outputs \
  -v $(pwd)/Extract:/app/Extract \
  -v $(pwd)/Load:/app/Load \
  atp-tour-etl:latest

# Windows PowerShell
docker run --rm -p 8501:8501 `
  -v ${PWD}/outputs:/app/outputs `
  -v ${PWD}/Extract:/app/Extract `
  -v ${PWD}/Load:/app/Load `
  atp-tour-etl:latest
```

**Resultado:**
- ✅ Todos los archivos generados persisten
- ✅ CSVs limpiados en `./Extract/`
- ✅ Bases de datos SQLite en `./Load/`
- ✅ Gráficas en `./outputs/`

---

### Opción 4: Modo Interactivo (para debugging)

```bash
docker run -it --rm atp-tour-etl:latest /bin/bash
```

**Resultado:**
- Abre una terminal dentro del contenedor
- Puedes ejecutar comandos manualmente:
  ```bash
  python analysis/analysis.py
  ls -lh outputs/
  streamlit run main.py
  ```

---

## 📊 Verificar la Salida

### Ver archivos generados

```bash
# Listar archivos en el directorio outputs
ls -lh outputs/

# Ver archivos procesados
ls -lh Extract/*.csv
ls -lh Load/*.db
```

### Salida esperada

```
outputs/
├── matches_per_year_surface.png  (~150 KB)
└── top10_winners.png              (~80 KB)

Extract/
└── atp_matches_2004_clean.csv     (~2 MB)

Load/
└── atp_database.db                (~5 MB)
```

---

## 🔍 Verificación del Contenedor

### Healthcheck (verificar estado)

```bash
# Ver estado del contenedor
docker ps -a

# Ver logs del healthcheck
docker inspect --format='{{json .State.Health}}' <container_id>
```

### Ver logs en tiempo real

```bash
# Ejecutar en modo detached
docker run -d --name atp-pipeline -p 8501:8501 atp-tour-etl:latest

# Ver logs en vivo
docker logs -f atp-pipeline

# Detener contenedor
docker stop atp-pipeline
```

---

## 🛠️ Comandos Útiles

### Gestión de Imágenes

```bash
# Listar imágenes locales
docker images

# Eliminar imagen
docker rmi atp-tour-etl:latest

# Ver tamaño de imagen
docker images atp-tour-etl --format "{{.Size}}"
```

### Gestión de Contenedores

```bash
# Listar contenedores en ejecución
docker ps

# Listar todos los contenedores (incluidos detenidos)
docker ps -a

# Eliminar todos los contenedores detenidos
docker container prune
```

### Limpieza

```bash
# Limpiar contenedores, imágenes sin usar, caché
docker system prune -a

# Limpiar todo (incluye volúmenes)
docker system prune -a --volumes
```

---

## 🐛 Troubleshooting

### Error: "No se encontró el directorio tennis_atp_data"

**Solución:**
```bash
# Verificar que el directorio existe
ls tennis_atp_data/

# Si no existe, asegurarse de estar en el directorio correcto
cd /workspaces/ATPtour
```

---

### Error: "docker: comando no encontrado"

**Solución:**
```bash
# Verificar instalación
docker --version

# Si no está instalado, descargar Docker Desktop
```

---

### Error: "cannot mount volume"

**Solución:**
```bash
# Linux/macOS: Usar rutas absolutas
docker run --rm -p 8501:8501 \
  -v /workspaces/ATPtour/outputs:/app/outputs \
  atp-tour-etl:latest

# Windows: Usar variable PWD
docker run --rm -p 8501:8501 `
  -v ${PWD}\outputs:/app/outputs `
  atp-tour-etl:latest
```

---

### Error: "port 8501 is already allocated"

**Solución:**
```bash
# Usar un puerto diferente (ejemplo: 8502)
docker run --rm -p 8502:8501 atp-tour-etl:latest

# Acceder en: http://localhost:8502
```

---

### Error: "Container exits immediately"

**Solución:**
```bash
# Ver los logs del último contenedor
docker logs $(docker ps -lq)

# Ejecutar en modo interactivo para debug
docker run -it --rm atp-tour-etl:latest /bin/bash
```

---

## 📦 Docker Compose (Opcional)

Si deseas gestionar el contenedor con Docker Compose, usa el archivo `docker-compose.yml` incluido:

```bash
# Construir y ejecutar
docker-compose up

# Ejecutar en segundo plano
docker-compose up -d

# Ver logs
docker-compose logs -f

# Detener
docker-compose down
```

---

## 🚀 Deploy en Cloud (Opcional)

### Docker Hub

```bash
# Login
docker login

# Tagear imagen
docker tag atp-tour-etl:latest tu-usuario/atp-tour-etl:latest

# Push
docker push tu-usuario/atp-tour-etl:latest
```

### AWS ECS / Azure Container Instances

```bash
# Exportar imagen a archivo tar
docker save -o atp-tour-etl.tar atp-tour-etl:latest

# Comprimir (opcional)
gzip atp-tour-etl.tar
```

---

## 📈 Casos de Uso

### 1. Análisis Batch (sin interfaz web)

```bash
docker run --rm \
  -v $(pwd)/outputs:/app/outputs \
  atp-tour-etl:latest \
  python -u analysis/analysis.py
```

### 2. Desarrollo Local con Streamlit

```bash
docker run --rm -p 8501:8501 \
  -v $(pwd):/app \
  atp-tour-etl:latest
```

### 3. Producción con Volúmenes Nombrados

```bash
# Crear volumen
docker volume create atp-data

# Ejecutar con volumen
docker run -d --name atp-prod \
  -p 8501:8501 \
  -v atp-data:/app/outputs \
  atp-tour-etl:latest
```

---

## 🎯 Workflows Recomendados

### Para Análisis de Datos (Data Scientist)

```bash
# 1. Construir imagen
docker build -t atp-tour-etl:latest .

# 2. Ejecutar análisis
docker run --rm -v $(pwd)/outputs:/app/outputs atp-tour-etl:latest python analysis/analysis.py

# 3. Ver resultados
ls -lh outputs/
```

### Para Desarrollo Web (Frontend Developer)

```bash
# 1. Construir imagen
docker build -t atp-tour-etl:latest .

# 2. Levantar Streamlit
docker run --rm -p 8501:8501 -v $(pwd):/app atp-tour-etl:latest

# 3. Abrir navegador en http://localhost:8501
```

### Para DevOps (Deployment)

```bash
# 1. Construir imagen optimizada
docker build --no-cache -t atp-tour-etl:v1.0 .

# 2. Escanear vulnerabilidades
trivy image atp-tour-etl:v1.0

# 3. Push a registry
docker tag atp-tour-etl:v1.0 registry.example.com/atp-tour-etl:v1.0
docker push registry.example.com/atp-tour-etl:v1.0
```

---

## ✅ Checklist de Ejecución

- [ ] Docker Desktop instalado y corriendo
- [ ] Navegaste al directorio `/workspaces/ATPtour`
- [ ] Verificaste que existe `tennis_atp_data/` con datos
- [ ] Construiste la imagen: `docker build -t atp-tour-etl:latest .`
- [ ] Ejecutaste con Streamlit: `docker run --rm -p 8501:8501 atp-tour-etl:latest`
- [ ] Accediste a http://localhost:8501
- [ ] Verificaste los archivos generados en `./outputs/`

---

## 📞 Soporte

Si tienes problemas:

1. Verifica los logs: `docker logs <container_id>`
2. Ejecuta en modo interactivo: `docker run -it --rm atp-tour-etl:latest /bin/bash`
3. Revisa el healthcheck: `docker inspect <container_id>`
4. Consulta `DOCKER_SECURITY.md` para mejores prácticas

---

**¡Feliz análisis de datos ATP! 🎾📊**
