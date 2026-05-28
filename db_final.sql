-- 1. USUARIOS
-- Tabla para almacenar la información de los usuarios registrados en la plataforma
CREATE TABLE usuarios (
    usuario_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    avatar_url VARCHAR(255),
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. CANALES
--Cada usuario tiene su propio canal (perfil)
CREATE TABLE canales (
    canal_id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT UNIQUE NOT NULL,
    nombre_canal VARCHAR(100) NOT NULL,
    descripcion TEXT,
    logo_url VARCHAR(255),
    stream_key VARCHAR(100) UNIQUE NOT NULL, -- Clave para OBS
    FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id) ON DELETE CASCADE
    --Hemos puesto foreign key de esto porque está relacionada la tabla de usuarios con canales. 1:1
);

--3. LIVE
--Cada usuario puede hacer lives a través de su canal y ver los lives de otra gente 
CREATE TABLE live (
    live_id INT AUTO_INCREMENT PRIMARY KEY,
    canal_id INT NOT NULL,
    titulo VARCHAR(100) NOT NULL,
    contenido TEXT,
    descripcion TEXT,
    inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fin TIMESTAMP NULL,
    estado ENUM('en_vivo', 'finalizado') DEFAULT 'en_vivo',
    FOREIGN KEY (canal_id) REFERENCES canales(canal_id) ON DELETE CASCADE
    --Esta foreign key conecta la ID del canal con la ID del directo. 1:1
)

-- 4. SEGUIDORES
--Cada canal tiene sus seguidores
CREATE TABLE seguidores (
    seguidor_id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL, -- Quien sigue
    canal_id INT NOT NULL,   -- Canal seguido
    UNIQUE(usuario_id, canal_id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id) ON DELETE CASCADE,
    --Foreign key aquí hace la función de recopilar todos los seguidores del usuario N:1
    FOREIGN KEY (canal_id) REFERENCES canales(canal_id) ON DELETE CASCADE
    --Tiene la misma función igual que anterior. N:1
);

-- 5. HISTORIAL (Registro de transmisiones pasadas)
--Cada usuario tiene un historial
CREATE TABLE historial (
    usuario_id INT NOT NULL,
    historial_id INT AUTO_INCREMENT PRIMARY KEY,
    canal_id INT NOT NULL,
    contenido TEXT NOT NULL,
    FOREIGN KEY (contenido) REFERENCES live(contenido) ON DELETE CASCADE,
    --La foreign key va aquí porque cada contenido tendrá historial. N:1
    FOREIGN KEY (canal_id) REFERENCES canales(canal_id) ON DELETE CASCADE,
    --Se guardará cada canal que ha visitado el usuario. N:1
    FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id) ON DELETE CASCADE
    --Necesitamos ID de usuario para asignar internamente una página de sugerencias a cada usuario. 1:1
);

-- 6. CHAT LIVE (Mensajes en tiempo real en los directos)
CREATE TABLE chat_live (
    mensaje_live_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id) ON DELETE CASCADE
    --Esta foreign key une el mensaje de cada usuario con chat. 1:1
);

-- 7. CHAT PRIVADO (Mensajería directa entre usuarios)
CREATE TABLE chat_privado (
    mensaje_privado_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    remitente_id INT NOT NULL,
    destinatario_id INT NOT NULL,
    contenido_texto TEXT NOT NULL,
    leido BOOLEAN DEFAULT FALSE,
    enviado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (remitente_id) REFERENCES usuarios(usuario_id) ON DELETE CASCADE,
    --Esta foreign key une el mensaje de cada usuario con chat privado. 1:1
    FOREIGN KEY (destinatario_id) REFERENCES usuarios(usuario_id) ON DELETE CASCADE
    --Esta foreign key une el mensaje de cada usuario con chat privado. 1:1
);

-- 8. TIENDA (Productos digitales: emotes, medallas, stickers)
CREATE TABLE tienda (
    producto_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio_monedas INT NOT NULL, -- Precio en la moneda virtual de la plataforma
    imagen_url VARCHAR(255) NOT NULL,
    tipo ENUM('emote', 'badge', 'sticker') NOT NULL
);

-- 9. COLECCIÓN (Inventario de lo que compra el usuario)
CREATE TABLE coleccion (
    coleccion_id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    producto_id INT NOT NULL,
    UNIQUE(usuario_id, producto_id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id) ON DELETE CASCADE,
    --Es lo que une colección (inventario) con usuario. 1:1
    FOREIGN KEY (producto_id) REFERENCES tienda(producto_id) ON DELETE CASCADE
    --Es lo que une los productos con la colección. N:1
);

-- 10. BLOQUEADOS (Usuarios bloqueados para no ver su contenido o chat)
CREATE TABLE bloqueados (
    bloqueo_id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,      -- El que bloquea
    usuario_bloqueado_id INT NOT NULL, -- El bloqueado
    -- UNIQUE(usuario_id, usuario_bloqueado_id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id) ON DELETE CASCADE,
    --Necesitamos la ID del que está bloqueando. 1:1
    FOREIGN KEY (usuario_bloqueado_id) REFERENCES usuarios(usuario_id) ON DELETE CASCADE
    --Necesitamos la ID del usuario bloqueado N:1
);

-- 11. NOTIFICACIÓN
CREATE TABLE notificacion (
    notificacion_id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    titulo VARCHAR(100) NOT NULL,
    mensaje VARCHAR(255) NOT NULL,
    tipo ENUM('live_en_vivo', 'nuevo_seguidor', 'sistema', 'mensajes_nuevos') NOT NULL,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id) ON DELETE CASCADE
    --Un usuario puede recibir muchas notificaciones. N:1
);

-- 12. BILLETERA (Monedas virtuales de la plataforma)
CREATE TABLE billetera (
    billetera_id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT UNIQUE NOT NULL,
    saldo_monedas INT DEFAULT 0,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id) ON DELETE CASCADE
    --Es lo que junta al usuario con su billetera. 1:1
);

-- 13. REPORTES
CREATE TABLE reportes (
    reporte_id INT AUTO_INCREMENT PRIMARY KEY,
    denunciante_id INT NOT NULL,
    denunciado_id INT NOT NULL,
    motivo VARCHAR(500) NOT NULL,
    estado ENUM('pendiente', 'revisado', 'desestimado') DEFAULT 'pendiente',
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (denunciante_id) REFERENCES usuarios(usuario_id) ON DELETE CASCADE,
    --Necesitamos la ID del que está denunciando. 1:1
    FOREIGN KEY (denunciado_id) REFERENCES usuarios(usuario_id) ON DELETE CASCADE
    --Necesitamos la ID del que está siendo denunciado. N:1
);