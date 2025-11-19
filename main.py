import os
import pandas as pd
import streamlit as st

try:
    from Config.configuraciones import Config
except Exception:
    from configuraciones import Config
try:
    from Load.atpLoad import Loader
except Exception:
    from atpLoad import Loader

st.set_page_config(page_title="ETL ATP 2004", layout="wide")

# ==========================
# Estilos 
# ==========================
st.markdown(
    """
    <style>
    :root{--oscuro:#0C1A1A;--acento:#6ACFC7;--texto:#EAF8F7}
    .stApp{background:linear-gradient(180deg,#0C1A1A 0%, #102626 100%);color:var(--texto)}
    .block-container{padding-top:2rem;padding-bottom:2rem;}
    h1,h2,h3,label, .stTextInput label, .stSelectbox label, .stNumberInput label{color:var(--texto)!important}
    .stButton>button{background:var(--acento);color:var(--oscuro);border:0;border-radius:12px;padding:.6rem 1rem;font-weight:700}
    .stButton>button:hover{filter:brightness(1.05)}
    .metric-card{background:rgba(255,255,255,.04);border:1px solid rgba(106,207,199,.25);border-radius:16px;padding:1rem}
    .stTextInput>div>div>input,.stTextArea textarea,.stSelectbox>div>div,.stNumberInput>div>div>input{background:rgba(106,207,199,.08)!important;color:var(--texto)!important;border:1px solid rgba(106,207,199,.35)!important;border-radius:12px!important}
    </style>
    """,
    unsafe_allow_html=True,
)

st.title("ETL ATP 2004 • Interfaz")

# ==========================
# Selección de archivo restringida
# ==========================
DATA_DIR = "/workspaces/ATPtour/tennis_atp_data"

with st.sidebar:
    st.header("Origen de datos (carpeta fija)")
    st.caption("Solo puedes elegir archivos dentro de:")
    st.code(DATA_DIR, language="bash")

    # Listar CSVs disponibles
    try:
        csv_files = [f for f in os.listdir(DATA_DIR) if f.lower().endswith(".csv") and os.path.isfile(os.path.join(DATA_DIR, f))]
    except Exception as e:
        st.error(f"No se pudo acceder a {DATA_DIR}: {e}")
        st.stop()

    if not csv_files:
        st.warning("No hay archivos .csv en la carpeta indicada.")
        st.stop()

    csv_files = sorted(csv_files)
    selected_name = st.selectbox("Archivo CSV disponible", csv_files, index=0)
    selected_path = os.path.join(DATA_DIR, selected_name)
    st.caption(f"Archivo seleccionado: {selected_name}")

    st.header("Limpieza")
    eliminar_dups = st.checkbox("Eliminar duplicados", True)
    eliminar_na = st.checkbox("Eliminar filas vacías", False)
    normalizar_cols = st.checkbox("Normalizar nombres de columnas", True)

# ==========================
# Carga y limpieza
# ==========================
try:
    df = pd.read_csv(selected_path)
except Exception as e:
    st.error(f"Error al leer el CSV seleccionado: {e}")
    st.stop()

df_original = df.copy()

if normalizar_cols:
    df.columns = df.columns.str.strip().str.lower().str.replace(" ", "_", regex=False)
if eliminar_dups:
    df = df.drop_duplicates()
if eliminar_na:
    df = df.dropna()

# ==========================
# Métricas y vista previa
# ==========================
c1,c2,c3 = st.columns(3)
with c1:
    st.markdown('<div class="metric-card">', unsafe_allow_html=True)
    st.metric("Filas", f"{df.shape[0]:,}")
    st.markdown('</div>', unsafe_allow_html=True)
with c2:
    st.markdown('<div class="metric-card">', unsafe_allow_html=True)
    st.metric("Columnas", f"{df.shape[1]:,}")
    st.markdown('</div>', unsafe_allow_html=True)
with c3:
    st.markdown('<div class="metric-card">', unsafe_allow_html=True)
    st.metric("Duplicados eliminados", f"{max(df_original.shape[0]-df.shape[0], 0):,}")
    st.markdown('</div>', unsafe_allow_html=True)

st.subheader("Vista previa")
st.dataframe(df.head(50), width='stretch')

# ==========================
# Guardado
# ==========================
st.subheader("Guardar")
colA, colB = st.columns(2)

with colA:
    output_csv_path = st.text_input("Ruta CSV de salida", "/workspaces/ATPtour/Extract/atp_matches_2004_clean.csv")
    if st.button("Guardar CSV limpio"):
        loader = Loader(df)
        try:
            loader.to_csv(output_csv_path)
            st.success(f"CSV guardado en {output_csv_path}")
        except Exception as e:
            st.error(str(e))

with colB:
    db_path = st.text_input("Ruta SQLite", Config.SQLITE_DB_PATH)
    table_name = st.text_input("Tabla", Config.SQLITE_TABLE)
    if st.button("Guardar en SQLite"):
        loader = Loader(df)
        try:
            loader.to_sqlite(db_path=db_path, table_name=table_name)
            st.success(f"Guardado en {db_path} (tabla {table_name})")
        except Exception as e:
            st.error(str(e))

csv_bytes = df.to_csv(index=False).encode("utf-8")
st.download_button("Descargar CSV limpio", data=csv_bytes, file_name="atp_matches_2004_clean.csv", mime="text/csv")

# ==========================
# Análisis global (gráficas)
# ==========================
import subprocess
import sys

ANALYSIS_SCRIPT = os.path.join(os.path.dirname(__file__), 'analysis', 'analysis.py')
OUT_DIR = os.path.join(os.path.dirname(__file__), 'outputs')
OUT_MATCHES = os.path.join(OUT_DIR, 'matches_per_year_surface.png')
OUT_TOP10 = os.path.join(OUT_DIR, 'top10_winners.png')

st.subheader("Análisis y gráficas")
col1, col2 = st.columns([1, 2])
with col1:
    if st.button("Regenerar gráficas"):
        try:
            proc = subprocess.run([sys.executable, ANALYSIS_SCRIPT], capture_output=True, text=True, check=True)
            st.success("Gráficas regeneradas correctamente.")
            st.code(proc.stdout)
        except subprocess.CalledProcessError as e:
            st.error("Error al generar las gráficas. Revisa la salida abajo.")
            st.code(e.stdout + "\n" + e.stderr)

    show_images = st.checkbox("Mostrar gráficas", True)

with col2:
    if show_images:
        imgs = []
        captions = []
        if os.path.exists(OUT_MATCHES):
            imgs.append(OUT_MATCHES); captions.append('Partidos por año y superficie')
        else:
            st.info(f'No se encontró {OUT_MATCHES}. Pulsa "Regenerar gráficas" para crearlo.')

        if os.path.exists(OUT_TOP10):
            imgs.append(OUT_TOP10); captions.append('Top 10 ganadores por victorias')
        else:
            st.info(f'No se encontró {OUT_TOP10}. Pulsa "Regenerar gráficas" para crearlo.')

        for img, cap in zip(imgs, captions):
            try:
                st.image(img, caption=cap, width='stretch')
            except Exception as e:
                st.error(f'No se pudo mostrar {img}: {e}')
