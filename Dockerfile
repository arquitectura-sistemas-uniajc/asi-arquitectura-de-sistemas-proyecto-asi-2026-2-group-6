# Version 4: lo decente: multi-stage, usuario no root y verificación de salud.

# ---------- Etapa 1: dependencias ----------
FROM node:24-alpine AS dependencias
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev

# ---------- Etapa 2: imagen final ----------
FROM node:24-alpine
ENV NODE_ENV=production
WORKDIR /app

# Usuario sin privilegios
RUN addgroup -S app && adduser -S app -G app

# Se copia como dueño "app" ANTES de cambiar de usuario
COPY --from=dependencias --chown=app:app /app/node_modules ./node_modules
COPY --chown=app:app package.json ./
COPY --chown=app:app src ./src

USER app
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD wget -qO- http://localhost:3000/health || exit 1

CMD ["node", "src/index.js"]