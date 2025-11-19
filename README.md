# 🎾 ATP Tour Data Analysis - Pipeline ETL

Pipeline ETL completo para análisis de datos históricos del ATP Tour (1968-2023). Incluye extracción, transformación, carga y visualización interactiva con Streamlit.

## 📊 Características

- **Datos históricos**: 872,000+ partidos ATP desde 1968
- **Análisis visual**: Gráficas de tendencias por año, superficie y jugadores
- **ETL automatizado**: Limpieza, transformación y carga a múltiples formatos
- **Interfaz web**: Streamlit para exploración interactiva
- **Dockerizado**: Despliegue fácil en cualquier plataforma

## 🚀 Inicio Rápido

### Opción 1: Ejecutar con Docker (Recomendado)

```bash
# Construir imagen
docker build -t atp-tour-etl:latest .

# Ejecutar Streamlit
docker run --rm -p 8501:8501 -v $(pwd)/outputs:/app/outputs atp-tour-etl:latest

# Abrir navegador en http://localhost:8501
```

Ver [DOCKER_QUICKSTART.md](DOCKER_QUICKSTART.md) para más opciones.

### Opción 2: Ejecutar Localmente

```bash
# Instalar dependencias
pip install -r requirementes.txt

# Ejecutar análisis
python analysis/analysis.py

# Ejecutar Streamlit
streamlit run main.py
```

## 📁 Estructura del Proyecto

```
ATPtour/
├── tennis_atp_data/          # Datos fuente (CSVs ATP 1968-2023)
├── analysis/                 # Scripts de análisis
│   ├── analysis.py          # Pipeline de análisis principal
│   └── README_analysis.md   # Documentación del análisis
├── Config/                   # Configuraciones del proyecto
├── Extract/                  # Módulos de extracción
├── Transform/                # Módulos de transformación (si existen)
├── Load/                     # Módulos de carga a BD
├── outputs/                  # Gráficas generadas
├── main.py                   # Aplicación Streamlit
├── Dockerfile               # Configuración Docker
├── docker-compose.yml       # Orquestación Docker Compose
└── requirementes.txt        # Dependencias Python

```

## 📈 Gráficas Generadas

1. **Partidos por Año y Superficie**: Gráfico apilado que muestra la evolución del número de partidos por superficie (hard, clay, grass, carpet)
2. **Top 10 Ganadores**: Ranking de los 10 jugadores con más victorias en la historia del ATP

## 🐳 Docker

### Comandos Útiles

```bash
# Build
docker build -t atp-tour-etl:latest .

# Run análisis batch
docker run --rm -v $(pwd)/outputs:/app/outputs atp-tour-etl:latest python analysis/analysis.py

# Run Streamlit
docker run --rm -p 8501:8501 atp-tour-etl:latest

# Docker Compose
docker-compose up -d
```

### Documentación Docker

- [DOCKER_QUICKSTART.md](DOCKER_QUICKSTART.md) - Inicio rápido
- [DOCKER_INSTRUCTIONS.md](DOCKER_INSTRUCTIONS.md) - Guía completa
- [DOCKER_SECURITY.md](DOCKER_SECURITY.md) - Mejores prácticas de seguridad

## 🔧 Requisitos

- Python 3.12+
- Docker (opcional, recomendado)
- 4 GB RAM
- 2 GB espacio en disco

## 📦 Dependencias Principales

- `pandas >= 2.2` - Manipulación de datos
- `streamlit >= 1.36` - Interfaz web interactiva
- `matplotlib >= 3.7` - Visualizaciones
- `seaborn >= 0.12` - Gráficos estadísticos
- `SQLAlchemy >= 2.0` - ORM para bases de datos

## 🛠️ Uso

### Interfaz Streamlit

1. Selecciona un archivo CSV de la carpeta `tennis_atp_data/`
2. Aplica transformaciones (eliminar duplicados, normalizar columnas)
3. Visualiza estadísticas y vista previa
4. Guarda resultados en CSV o SQLite
5. Genera y visualiza gráficas de análisis

### Scripts de Análisis

```bash
# Ejecutar análisis completo
python analysis/analysis.py

# Ver gráficas generadas
ls -lh outputs/
```

## 📊 Datos

El proyecto utiliza datos históricos del ATP Tour disponibles en:
- Fuente: [JeffSackmann/tennis_atp](https://github.com/JeffSackmann/tennis_atp)
- Cobertura: 1968-2023
- Registros: ~872,000 partidos

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit cambios (`git commit -m 'Añadir nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT.

## 👤 Autor

**DSArevalo4**
- GitHub: [@DSArevalo4](https://github.com/DSArevalo4)

---

**¡Disfruta analizando datos del ATP Tour! 🎾📊**

