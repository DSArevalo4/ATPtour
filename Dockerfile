# Dockerfile para Pipeline ETL - ATP Tour Data Analysis
# Basado en Python 3.12 slim (última versión estable con soporte LTS)
# Optimizado para seguridad y mejores prácticas

FROM python:3.12-slim

# Metadata del contenedor
LABEL maintainer="Proyecto ETL - ATP Tour Analysis"
LABEL version="2.0"
LABEL description="Pipeline ETL para análisis de datos ATP Tour (1968-2023)"
LABEL org.opencontainers.image.source="https://github.com/DSArevalo4/ATPtour"
LABEL org.opencontainers.image.licenses="MIT"

# Establecer variables de entorno optimizadas
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PYTHONHASHSEED=random \
    DEBIAN_FRONTEND=noninteractive

# Crear usuario no-root para mayor seguridad
RUN groupadd -r appuser && useradd -r -g appuser -u 1001 -m -s /sbin/nologin appuser

# Crear directorio de trabajo y establecer permisos
WORKDIR /app

# Instalar dependencias del sistema necesarias y limpiar caché
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*

# Actualizar pip, setuptools y wheel a las últimas versiones
RUN pip install --no-cache-dir --upgrade \
    pip==24.2 \
    setuptools==75.1.0 \
    wheel==0.44.0

# Copiar archivo de requerimientos primero (mejor uso de caché de Docker)
COPY --chown=appuser:appuser requirementes.txt .

# Instalar dependencias de Python con versiones verificadas
RUN pip install --no-cache-dir -r requirementes.txt \
    && pip check

# Copiar todo el código fuente del proyecto con permisos correctos
COPY --chown=appuser:appuser . .

# Crear los directorios necesarios con permisos apropiados
RUN mkdir -p outputs Extract/Files Load/data && \
    chown -R appuser:appuser outputs Extract Load

# Dar permisos de escritura al directorio de trabajo
RUN chown -R appuser:appuser /app

# Verificar que los datos ATP existen
RUN if [ ! -d tennis_atp_data ]; then \
        echo "ERROR: No se encontró el directorio tennis_atp_data"; \
        exit 1; \
    fi

# Verificar integridad de los módulos Python
RUN python -c "import sys; import pandas; import matplotlib; import seaborn; print('✅ Dependencias verificadas correctamente')"

# Cambiar a usuario no-root
USER appuser

# Exponer puerto para Streamlit
EXPOSE 8501

# Healthcheck mejorado para verificar funcionamiento completo
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import pandas, matplotlib, seaborn, streamlit; print('✅ Container healthy')" || exit 1

# Comando por defecto: ejecutar análisis y luego Streamlit
CMD ["sh", "-c", "python -u analysis/analysis.py && streamlit run main.py --server.address=0.0.0.0 --server.port=8501"]
