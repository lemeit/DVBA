from qgis.core import (QgsField, QgsProject, QgsVectorLayer, 
                       QgsFeature, QgsGeometry)
from PyQt5.QtCore import QVariant
from PyQt5.QtWidgets import QInputDialog
import re

# Configuración Institucional
META_RESUMEN = "DVBA - Zona VI Saladillo - Div. Técnica (Ing. Luciano Lamaita)"

nombres_capas = [layer.name() for layer in QgsProject.instance().mapLayers().values()]
capa_org_nombre, ok1 = QInputDialog.getItem(None, "Origen", "Capa ORIGEN (Info Google):", nombres_capas, 0, False)
capa_geo_nombre, ok2 = QInputDialog.getItem(None, "Destino", "Capa DESTINO (Tu Geometría):", nombres_capas, 0, False)

if ok1 and ok2:
    capa_org = QgsProject.instance().mapLayersByName(capa_org_nombre)[0]
    capa_geo = QgsProject.instance().mapLayersByName(capa_geo_nombre)[0]
    match_ruta = re.search(r'(\d+)', capa_geo.name())
    num_ruta = int(match_ruta.group(1)) if match_ruta else 0

    campos_finales = QgsFields()
    campos_finales.append(QgsField("id", QVariant.Int))
    campos_finales.append(QgsField("rtn", QVariant.Int))
    campos_finales.append(QgsField("ruta_numer", QVariant.String))
    campos_finales.append(QgsField("name", QVariant.String))
    campos_finales.append(QgsField("km_value", QVariant.Double))
    campos_finales.append(QgsField("sentido_prog", QVariant.String)) # AQUÍ LA MEJORA
    campos_finales.append(QgsField("tipo_mojon", QVariant.String))
    campos_finales.append(QgsField("altitudeMo", QVariant.String))
    campos_finales.append(QgsField("tessellate", QVariant.Int))
    campos_finales.append(QgsField("extrude", QVariant.Int))
    campos_finales.append(QgsField("visibility", QVariant.Int))
    campos_finales.append(QgsField("referencia", QVariant.String))

    v_layer = QgsVectorLayer(f"Point?crs={capa_geo.crs().authid()}", f"RP{num_ruta}_Final_Corregida", "memory")
    v_layer.dataProvider().addAttributes(campos_finales)
    v_layer.updateFields()

    features_org = list(capa_org.getFeatures())
    features_geo = list(capa_geo.getFeatures())
    
    c_name_org = next((f.name() for f in capa_org.fields() if f.name().lower() == 'name'), "Name")
    c_desc_org = next((f.name() for f in capa_org.fields() if f.name().lower() in ['description', 'descriptio']), "description")

    new_features = []
    for i in range(len(features_geo)):
        f_nueva = QgsFeature(campos_finales)
        f_nueva.setGeometry(features_geo[i].geometry())
        
        km_val = 0.0
        name_val = ""
        sentido = "A confirmar"
        
        if i < len(features_org):
            fo = features_org[i]
            name_val = str(fo[c_name_org])
            m_km = re.search(r'(\d+)', name_val)
            km_val = float(m_km.group(1)) if m_km else 0.0
            
            # --- MEJORA EN LA EXTRACCIÓN DEL SENTIDO ---
            if fo[c_desc_org]:
                txt = str(fo[c_desc_org])
                # Busca lo que esté después de "dirección " o "direccion " hasta el final
                m_sent = re.search(r'(?:direcci[oó]n\s+)(.*)', txt, re.IGNORECASE)
                if m_sent:
                    sentido = m_sent.group(1).strip().upper()
                else:
                    # Si no encuentra la palabra dirección, limpia lo básico pero protege las siglas
                    sentido = txt.replace("Aumenta en ", "").strip().upper()
            
            alt_mode = fo['altitudeMo'] if 'altitudeMo' in fo.fields().names() else "clampToGround"
            tess = fo['tessellate'] if 'tessellate' in fo.fields().names() else -1
            ext = fo['extrude'] if 'extrude' in fo.fields().names() else 0
            vis = fo['visibility'] if 'visibility' in fo.fields().names() else 1

        f_nueva.setAttributes([
            i + 1, num_ruta, f"RP {num_ruta}", name_val, km_val, 
            sentido, "Cincuentakilométrico", alt_mode, tess, ext, vis, META_RESUMEN
        ])
        new_features.append(f_nueva)

    v_layer.dataProvider().addFeatures(new_features)
    QgsProject.instance().addMapLayer(v_layer)
    print("✅ Capa generada respetando sentidos compuestos (NO, SE, SO).")