#!/bin/bash

# ============================================
# FLASK PROJECT GENERATOR - FLASK MAKER
# Autor: Luigi Adducci (https://github.com/LuigiValentino)
# ============================================

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Variables globales
PROJECT_NAME=""
PROJECT_PATH=""
AUTHOR_NAME="Luigi Adducci"
AUTHOR_GITHUB="https://github.com/LuigiValentino"
GENERATOR_NAME="FlaskProyect Maker"

# Opciones de librerías (todas inicialmente desactivadas)
declare -A LIBRARIES=(
    # Flask extensions
    ["flask_sqlalchemy"]=0
    ["flask_login"]=0
    ["flask_wtf"]=0
    ["flask_migrate"]=0
    ["flask_restx"]=0
    ["flask_mail"]=0
    ["flask_admin"]=0
    ["flask_socketio"]=0
    ["flask_babel"]=0
    ["flask_limiter"]=0
    
    # Database
    ["psycopg2"]=0
    ["pymysql"]=0
    ["redis"]=0
    ["celery"]=0
    
    # Frontend/CSS
    ["bootstrap"]=0
    ["tailwind"]=0
    ["fontawesome"]=0
    ["jquery"]=0
    ["alpinejs"]=0
    ["axios"]=0
    
    # Utilities
    ["pandas"]=0
    ["numpy"]=0
    ["matplotlib"]=0
    ["requests"]=0
    ["pillow"]=0
    ["python_jwt"]=0
    ["pyjwt"]=0
    
    # Testing
    ["pytest"]=0
    ["coverage"]=0
    ["faker"]=0
    
    # Deployment
    ["gunicorn"]=0
    ["whitenoise"]=0
    ["sentry_sdk"]=0
)

# Opciones de características
USE_VENV=0
USE_GIT=0
USE_DOCKER=0
USE_DOCKER_COMPOSE=0
USE_MAKEFILE=0
USE_NGINX=0
USE_GITHUB_ACTIONS=0
USE_HEROKU=0
USE_AWS=0
USE_AUTH_SYSTEM=0
USE_API=0
USE_WEBSOCKET=0
USE_CACHE=0
USE_EMAIL=0
USE_FILE_UPLOAD=0
USE_PAYMENTS=0
USE_GRAPHS=0
USE_LOGGING=0

# Funciones de utilidad
print_header() {
    clear
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════╗"
    echo "║      FLASK PROJECT MAKER - v2.0         ║"
    echo "║    Generador de proyectos Flask         ║"
    echo "║    Creado por: Luigi Adducci            ║"
    echo "║    GitHub: https://github.com/LuigiValentino ║"
    echo "╚══════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_step() {
    echo -e "\n${BLUE}[+]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

ask_yes_no() {
    local question="$1"
    local default="${2:-no}"
    
    local options="[s/n]"
    if [[ "$default" == "yes" ]]; then
        options="[S/n]"
    elif [[ "$default" == "no" ]]; then
        options="[s/N]"
    fi
    
    while true; do
        read -p "$question $options: " answer
        answer=${answer:-$default}
        
        case "$answer" in
            [Ss]*|[Yy]*) return 0 ;;
            [Nn]*) return 1 ;;
            *) echo "Por favor responde s o n" ;;
        esac
    done
}

ask_input() {
    local question="$1"
    local default="$2"
    
    if [ -n "$default" ]; then
        read -p "$question [$default]: " input
        echo "${input:-$default}"
    else
        read -p "$question: " input
        echo "$input"
    fi
}

show_menu() {
    local title="$1"
    shift
    local options=("$@")
    
    echo -e "\n${CYAN}$title${NC}"
    for i in "${!options[@]}"; do
        echo "$((i+1)). ${options[$i]}"
    done
}

select_option() {
    local options=("$@")
    local total=${#options[@]}
    
    while true; do
        echo ""
        for i in "${!options[@]}"; do
            echo "$((i+1)). ${options[$i]}"
        done
        
        echo ""
        read -p "Selecciona una opción [1-$total]: " choice
        
        # Verificar si es un número
        if [[ "$choice" =~ ^[0-9]+$ ]]; then
            if [ "$choice" -ge 1 ] && [ "$choice" -le "$total" ]; then
                return $((choice-1))
            else
                echo -e "${RED}Opción inválida. Debe ser entre 1 y $total.${NC}"
            fi
        else
            echo -e "${RED}Por favor ingresa un número.${NC}"
        fi
    done
}

# Menús de selección
select_project_type() {
    print_step "Selecciona el tipo de proyecto:"
    
    local options=(
        "🚀 Proyecto Básico (Solo Flask esencial)"
        "💼 Proyecto Estándar (Web app completa)"
        "🔌 Proyecto API (REST API focused)"
        "📱 Proyecto Fullstack (Frontend + Backend)"
        "🏢 Proyecto Empresarial (Escalable)"
        "🎨 Personalizado (Elige todo manualmente)"
    )
    
    select_option "${options[@]}"
    local choice=$?
    
    case $choice in
        0) setup_basic_project ;;
        1) setup_standard_project ;;
        2) setup_api_project ;;
        3) setup_fullstack_project ;;
        4) setup_enterprise_project ;;
        5) setup_custom_project ;;
    esac
}

select_database() {
    print_step "Selecciona base de datos:"
    
    local options=(
        "SQLite (Recomendado para desarrollo)"
        "PostgreSQL (Producción)"
        "MySQL"
        "MongoDB (NoSQL)"
        "Varias bases de datos"
        "Sin base de datos"
    )
    
    select_option "${options[@]}"
    local choice=$?
    
    case $choice in
        0) 
            LIBRARIES["flask_sqlalchemy"]=1
            ;;
        1) 
            LIBRARIES["flask_sqlalchemy"]=1
            LIBRARIES["psycopg2"]=1
            ;;
        2) 
            LIBRARIES["flask_sqlalchemy"]=1
            LIBRARIES["pymysql"]=1
            ;;
        3)
            LIBRARIES["flask_mongoengine"]=1
            ;;
        4)
            LIBRARIES["flask_sqlalchemy"]=1
            LIBRARIES["redis"]=1
            ;;
        5) ;;
    esac
    
    if [ $choice -ne 5 ]; then
        LIBRARIES["flask_migrate"]=1
    fi
}

select_frontend() {
    print_step "Selecciona framework frontend:"
    
    local options=(
        "Bootstrap 5 (Recomendado)"
        "Tailwind CSS"
        "Bulma CSS"
        "Materialize CSS"
        "Solo CSS personalizado"
        "Sin CSS framework"
    )
    
    select_option "${options[@]}"
    local choice=$?
    
    case $choice in
        0) 
            LIBRARIES["bootstrap"]=1
            LIBRARIES["jquery"]=1
            ;;
        1) LIBRARIES["tailwind"]=1 ;;
        2) LIBRARIES["bulma"]=1 ;;
        3) LIBRARIES["materialize"]=1 ;;
        4) ;;
        5) ;;
    esac
    
    # Preguntar por JavaScript adicional
    if ask_yes_no "¿Incluir Alpine.js?" "no"; then
        LIBRARIES["alpinejs"]=1
    fi
    
    if ask_yes_no "¿Incluir Font Awesome?" "no"; then
        LIBRARIES["fontawesome"]=1
    fi
    
    if ask_yes_no "¿Incluir Axios para peticiones HTTP?" "yes"; then
        LIBRARIES["axios"]=1
    fi
}

select_auth_method() {
    print_step "Selecciona método de autenticación:"
    
    local options=(
        "Flask-Login (Sesiones tradicionales)"
        "JWT Tokens (Para APIs)"
        "OAuth (Google, Facebook, etc.)"
        "LDAP/Active Directory"
        "Doble factor de autenticación"
        "Sin autenticación"
    )
    
    select_option "${options[@]}"
    local choice=$?
    
    case $choice in
        0) 
            LIBRARIES["flask_login"]=1
            USE_AUTH_SYSTEM=1
            ;;
        1) 
            LIBRARIES["pyjwt"]=1
            USE_AUTH_SYSTEM=1
            USE_API=1
            ;;
        2) 
            LIBRARIES["flask_dance"]=1
            USE_AUTH_SYSTEM=1
            ;;
        3)
            LIBRARIES["flask_ldap3_login"]=1
            USE_AUTH_SYSTEM=1
            ;;
        4)
            LIBRARIES["flask_login"]=1
            LIBRARIES["pyotp"]=1
            USE_AUTH_SYSTEM=1
            ;;
        5) ;;
    esac
}

select_api_type() {
    print_step "Selecciona tipo de API:"
    
    local options=(
        "Flask-RESTx (Recomendado, con Swagger UI)"
        "Flask-RESTful"
        "GraphQL (Graphene)"
        "gRPC"
        "WebSocket (Socket.IO)"
        "Sin API"
    )
    
    select_option "${options[@]}"
    local choice=$?
    
    case $choice in
        0) 
            LIBRARIES["flask_restx"]=1
            USE_API=1
            ;;
        1) 
            LIBRARIES["flask_restful"]=1
            USE_API=1
            ;;
        2) 
            LIBRARIES["graphene"]=1
            USE_API=1
            ;;
        3) 
            LIBRARIES["grpcio"]=1
            USE_API=1
            ;;
        4) 
            LIBRARIES["flask_socketio"]=1
            USE_WEBSOCKET=1
            USE_API=1
            ;;
        5) ;;
    esac
}

select_deployment() {
    print_step "Selecciona opciones de despliegue:"
    
    if ask_yes_no "¿Usar Docker?" "yes"; then
        USE_DOCKER=1
    fi
    
    if ask_yes_no "¿Usar Docker Compose?" "yes"; then
        USE_DOCKER_COMPOSE=1
    fi
    
    if ask_yes_no "¿Configurar Nginx como reverse proxy?" "yes"; then
        USE_NGINX=1
    fi
    
    if ask_yes_no "¿Configurar GitHub Actions para CI/CD?" "no"; then
        USE_GITHUB_ACTIONS=1
    fi
    
    if ask_yes_no "¿Configurar para Heroku?" "no"; then
        USE_HEROKU=1
    fi
    
    if ask_yes_no "¿Configurar para AWS?" "no"; then
        USE_AWS=1
    fi
}

select_extra_features() {
    print_step "Selecciona características adicionales:"
    
    if ask_yes_no "¿Sistema de envío de emails?" "yes"; then
        LIBRARIES["flask_mail"]=1
        USE_EMAIL=1
    fi
    
    if ask_yes_no "¿Sistema de subida de archivos?" "yes"; then
        LIBRARIES["pillow"]=1
        USE_FILE_UPLOAD=1
    fi
    
    if ask_yes_no "¿Sistema de caché con Redis?" "no"; then
        LIBRARIES["redis"]=1
        USE_CACHE=1
    fi
    
    if ask_yes_no "¿Tareas asíncronas con Celery?" "no"; then
        LIBRARIES["celery"]=1
    fi
    
    if ask_yes_no "¿Sistema de pagos (Stripe/PayPal)?" "no"; then
        USE_PAYMENTS=1
    fi
    
    if ask_yes_no "¿Gráficos y reportes?" "no"; then
        LIBRARIES["matplotlib"]=1
        LIBRARIES["pandas"]=1
        USE_GRAPHS=1
    fi
    
    if ask_yes_no "¿Sistema de logging avanzado?" "yes"; then
        USE_LOGGING=1
    fi
    
    if ask_yes_no "¿Internacionalización (i18n)?" "no"; then
        LIBRARIES["flask_babel"]=1
    fi
    
    if ask_yes_no "¿Panel de administración (Flask-Admin)?" "yes"; then
        LIBRARIES["flask_admin"]=1
    fi
    
    if ask_yes_no "¿Rate limiting para API?" "yes"; then
        LIBRARIES["flask_limiter"]=1
    fi
    
    if ask_yes_no "¿Monitoring con Sentry?" "no"; then
        LIBRARIES["sentry_sdk"]=1
    fi
}

select_libraries() {
    print_step "Selección de librerías específicas"
    
    echo -e "\n${YELLOW}Librerías de Flask:${NC}"
    for lib in flask_sqlalchemy flask_login flask_wtf flask_migrate flask_restx flask_mail flask_admin; do
        if ask_yes_no "  ¿$lib?" "no"; then
            LIBRARIES[$lib]=1
        fi
    done
    
    echo -e "\n${YELLOW}Librerías de base de datos:${NC}"
    for lib in psycopg2 pymysql redis; do
        if ask_yes_no "  ¿$lib?" "no"; then
            LIBRARIES[$lib]=1
        fi
    done
    
    echo -e "\n${YELLOW}Librerías de frontend:${NC}"
    for lib in bootstrap tailwind jquery alpinejs axios fontawesome; do
        if ask_yes_no "  ¿$lib?" "no"; then
            LIBRARIES[$lib]=1
        fi
    done
    
    echo -e "\n${YELLOW}Librerías de utilidades:${NC}"
    for lib in pandas numpy matplotlib requests pillow; do
        if ask_yes_no "  ¿$lib?" "no"; then
            LIBRARIES[$lib]=1
        fi
    done
    
    echo -e "\n${YELLOW}Librerías de testing:${NC}"
    for lib in pytest coverage faker; do
        if ask_yes_no "  ¿$lib?" "no"; then
            LIBRARIES[$lib]=1
        fi
    done
    
    echo -e "\n${YELLOW}Librerías de despliegue:${NC}"
    for lib in gunicorn whitenoise; do
        if ask_yes_no "  ¿$lib?" "no"; then
            LIBRARIES[$lib]=1
        fi
    done
}

# Configuraciones predefinidas
setup_basic_project() {
    print_step "Configurando proyecto básico..."
    LIBRARIES["flask_sqlalchemy"]=1
    LIBRARIES["flask_login"]=1
    LIBRARIES["flask_wtf"]=1
    LIBRARIES["flask_migrate"]=1
    LIBRARIES["bootstrap"]=1
    LIBRARIES["jquery"]=1
    USE_VENV=1
    USE_GIT=1
    USE_AUTH_SYSTEM=1
    USE_EMAIL=1
}

setup_standard_project() {
    print_step "Configurando proyecto estándar..."
    LIBRARIES["flask_sqlalchemy"]=1
    LIBRARIES["flask_login"]=1
    LIBRARIES["flask_wtf"]=1
    LIBRARIES["flask_migrate"]=1
    LIBRARIES["flask_mail"]=1
    LIBRARIES["flask_admin"]=1
    LIBRARIES["bootstrap"]=1
    LIBRARIES["jquery"]=1
    LIBRARIES["fontawesome"]=1
    LIBRARIES["pytest"]=1
    LIBRARIES["gunicorn"]=1
    USE_VENV=1
    USE_GIT=1
    USE_DOCKER=1
    USE_DOCKER_COMPOSE=1
    USE_AUTH_SYSTEM=1
    USE_API=1
    USE_EMAIL=1
    USE_FILE_UPLOAD=1
}

setup_api_project() {
    print_step "Configurando proyecto API..."
    LIBRARIES["flask_sqlalchemy"]=1
    LIBRARIES["flask_migrate"]=1
    LIBRARIES["flask_restx"]=1
    LIBRARIES["pyjwt"]=1
    LIBRARIES["flask_limiter"]=1
    LIBRARIES["redis"]=1
    LIBRARIES["celery"]=1
    LIBRARIES["pytest"]=1
    LIBRARIES["gunicorn"]=1
    USE_VENV=1
    USE_GIT=1
    USE_DOCKER=1
    USE_DOCKER_COMPOSE=1
    USE_API=1
    USE_CACHE=1
}

setup_fullstack_project() {
    print_step "Configurando proyecto Fullstack..."
    LIBRARIES["flask_sqlalchemy"]=1
    LIBRARIES["flask_login"]=1
    LIBRARIES["flask_wtf"]=1
    LIBRARIES["flask_migrate"]=1
    LIBRARIES["flask_restx"]=1
    LIBRARIES["flask_socketio"]=1
    LIBRARIES["bootstrap"]=1
    LIBRARIES["tailwind"]=1
    LIBRARIES["alpinejs"]=1
    LIBRARIES["axios"]=1
    LIBRARIES["fontawesome"]=1
    LIBRARIES["redis"]=1
    LIBRARIES["celery"]=1
    LIBRARIES["pytest"]=1
    USE_VENV=1
    USE_GIT=1
    USE_DOCKER=1
    USE_DOCKER_COMPOSE=1
    USE_NGINX=1
    USE_AUTH_SYSTEM=1
    USE_API=1
    USE_WEBSOCKET=1
    USE_CACHE=1
    USE_EMAIL=1
}

setup_enterprise_project() {
    print_step "Configurando proyecto empresarial..."
    # Todas las características activadas
    for lib in "${!LIBRARIES[@]}"; do
        LIBRARIES[$lib]=1
    done
    USE_VENV=1
    USE_GIT=1
    USE_DOCKER=1
    USE_DOCKER_COMPOSE=1
    USE_NGINX=1
    USE_GITHUB_ACTIONS=1
    USE_HEROKU=1
    USE_AWS=1
    USE_AUTH_SYSTEM=1
    USE_API=1
    USE_WEBSOCKET=1
    USE_CACHE=1
    USE_EMAIL=1
    USE_FILE_UPLOAD=1
    USE_PAYMENTS=1
    USE_GRAPHS=1
    USE_LOGGING=1
}

setup_custom_project() {
    print_step "Configuración personalizada paso a paso..."
    
    if ask_yes_no "¿Base de datos?" "yes"; then
        select_database
    fi
    
    if ask_yes_no "¿Sistema de autenticación?" "yes"; then
        select_auth_method
    fi
    
    if ask_yes_no "¿API?" "yes"; then
        select_api_type
    fi
    
    if ask_yes_no "¿Frontend?" "yes"; then
        select_frontend
    fi
    
    if ask_yes_no "¿Características adicionales?" "yes"; then
        select_extra_features
    fi
    
    if ask_yes_no "¿Opciones de despliegue?" "yes"; then
        select_deployment
    fi
    
    if ask_yes_no "¿Seleccionar librerías manualmente?" "no"; then
        select_libraries
    fi
    
    # Preguntas básicas
    if ask_yes_no "¿Crear entorno virtual?" "yes"; then
        USE_VENV=1
    fi
    
    if ask_yes_no "¿Inicializar repositorio Git?" "yes"; then
        USE_GIT=1
    fi
    
    if ask_yes_no "¿Crear Makefile?" "yes"; then
        USE_MAKEFILE=1
    fi
}

# Función para obtener información del proyecto
get_project_info() {
    print_header
    
    echo -e "${CYAN}Configuración del proyecto${NC}\n"
    
    PROJECT_NAME=$(ask_input "Nombre del proyecto" "mi_flask_app")
    PROJECT_PATH="$PWD/$PROJECT_NAME"
    
    # Verificar si el directorio existe
    if [ -d "$PROJECT_PATH" ]; then
        echo -e "${RED}El directorio '$PROJECT_NAME' ya existe.${NC}"
        if ask_yes_no "¿Sobrescribirlo?" "no"; then
            rm -rf "$PROJECT_PATH"
        else
            PROJECT_NAME=$(ask_input "Nuevo nombre del proyecto" "${PROJECT_NAME}_$(date +%s)")
            PROJECT_PATH="$PWD/$PROJECT_NAME"
        fi
    fi
    
    # Preguntar tipo de proyecto
    select_project_type
    
    # Resumen de la configuración
    show_config_summary
}

show_config_summary() {
    print_header
    echo -e "${GREEN}Resumen de configuración:${NC}\n"
    
    echo -e "${CYAN}Proyecto:${NC} $PROJECT_NAME"
    echo -e "${CYAN}Ruta:${NC} $PROJECT_PATH"
    echo ""
    
    echo -e "${YELLOW}Características seleccionadas:${NC}"
    [ $USE_VENV -eq 1 ] && echo "  ✓ Entorno virtual"
    [ $USE_GIT -eq 1 ] && echo "  ✓ Repositorio Git"
    [ $USE_DOCKER -eq 1 ] && echo "  ✓ Docker"
    [ $USE_DOCKER_COMPOSE -eq 1 ] && echo "  ✓ Docker Compose"
    [ $USE_AUTH_SYSTEM -eq 1 ] && echo "  ✓ Sistema de autenticación"
    [ $USE_API -eq 1 ] && echo "  ✓ API REST"
    [ $USE_WEBSOCKET -eq 1 ] && echo "  ✓ WebSocket"
    [ $USE_CACHE -eq 1 ] && echo "  ✓ Sistema de caché"
    [ $USE_EMAIL -eq 1 ] && echo "  ✓ Sistema de emails"
    [ $USE_FILE_UPLOAD -eq 1 ] && echo "  ✓ Subida de archivos"
    
    echo -e "\n${YELLOW}Librerías principales:${NC}"
    for lib in "${!LIBRARIES[@]}"; do
        if [ ${LIBRARIES[$lib]} -eq 1 ]; then
            echo "  ✓ $lib"
        fi
    done
    
    echo ""
    if ask_yes_no "¿Confirmar y crear proyecto?" "yes"; then
        create_project
    else
        echo -e "${YELLOW}Configuración cancelada.${NC}"
        exit 0
    fi
}

# Creación del proyecto
create_project() {
    print_header
    print_step "Creando proyecto Flask..."
    
    # Crear directorio principal
    mkdir -p "$PROJECT_PATH"
    cd "$PROJECT_PATH" || exit 1
    
    # Crear estructura básica de carpetas
    create_directory_structure
    
    # Crear archivos de configuración
    create_config_files
    
    # Crear archivos Python
    create_python_files
    
    # Crear templates HTML
    create_templates
    
    # Crear archivos estáticos
    create_static_files
    
    # Crear archivos adicionales
    create_additional_files
    
    # Configurar entorno
    setup_environment
    
    print_success "Proyecto creado exitosamente!"
    show_final_instructions
}

create_directory_structure() {
    print_step "Creando estructura de directorios..."
    
    # Directorios principales
    mkdir -p app/{templates,static/{css,js,images,uploads},models,forms,routes,utils,config,blueprints,middleware,services}
    mkdir -p tests/{unit,integration,fixtures}
    mkdir -p migrations
    mkdir -p instance
    mkdir -p logs
    mkdir -p docs/{api,deployment,development}
    mkdir -p scripts/{deployment,maintenance}
    mkdir -p docker/{nginx,ssl}
    mkdir -p .github/workflows
    
    # Directorios adicionales según características
    [ $USE_API -eq 1 ] && mkdir -p app/api/{v1,routes,schemas}
    [ $USE_AUTH_SYSTEM -eq 1 ] && mkdir -p app/auth/{routes,forms,services}
    [ $USE_FILE_UPLOAD -eq 1 ] && mkdir -p app/uploads/{users,products,documents}
    [ $USE_CACHE -eq 1 ] && mkdir -p app/cache
    
    print_success "Estructura de directorios creada"
}

create_config_files() {
    print_step "Creando archivos de configuración..."
    
    # requirements.txt
    cat > requirements.txt << EOF
# Flask Core
Flask>=2.3.0
Werkzeug>=2.3.0
Jinja2>=3.1.0
click>=8.1.0

# Environment
python-dotenv>=1.0.0
EOF

    # Agregar librerías seleccionadas
    if [ ${LIBRARIES["flask_sqlalchemy"]} -eq 1 ]; then
        echo "Flask-SQLAlchemy>=3.0.0" >> requirements.txt
        echo "SQLAlchemy>=2.0.0" >> requirements.txt
    fi
    
    if [ ${LIBRARIES["flask_login"]} -eq 1 ]; then
        echo "Flask-Login>=0.6.0" >> requirements.txt
    fi
    
    if [ ${LIBRARIES["flask_wtf"]} -eq 1 ]; then
        echo "Flask-WTF>=1.1.0" >> requirements.txt
        echo "WTForms>=3.0.0" >> requirements.txt
    fi
    
    if [ ${LIBRARIES["flask_migrate"]} -eq 1 ]; then
        echo "Flask-Migrate>=4.0.0" >> requirements.txt
    fi
    
    if [ ${LIBRARIES["flask_restx"]} -eq 1 ]; then
        echo "Flask-RESTx>=1.1.0" >> requirements.txt
    fi
    
    if [ ${LIBRARIES["flask_mail"]} -eq 1 ]; then
        echo "Flask-Mail>=0.9.1" >> requirements.txt
    fi
    
    if [ ${LIBRARIES["flask_admin"]} -eq 1 ]; then
        echo "Flask-Admin>=1.6.0" >> requirements.txt
    fi
    
    if [ ${LIBRARIES["flask_socketio"]} -eq 1 ]; then
        echo "Flask-SocketIO>=5.3.0" >> requirements.txt
        echo "python-socketio>=5.8.0" >> requirements.txt
    fi
    
    if [ ${LIBRARIES["flask_babel"]} -eq 1 ]; then
        echo "Flask-Babel>=3.0.0" >> requirements.txt
    fi
    
    if [ ${LIBRARIES["flask_limiter"]} -eq 1 ]; then
        echo "Flask-Limiter>=3.3.0" >> requirements.txt
    fi
    
    # Database drivers
    if [ ${LIBRARIES["psycopg2"]} -eq 1 ]; then
        echo "psycopg2-binary>=2.9.0" >> requirements.txt
    fi
    
    if [ ${LIBRARIES["pymysql"]} -eq 1 ]; then
        echo "pymysql>=1.0.0" >> requirements.txt
    fi
    
    if [ ${LIBRARIES["redis"]} -eq 1 ]; then
        echo "redis>=4.5.0" >> requirements.txt
    fi
    
    if [ ${LIBRARIES["celery"]} -eq 1 ]; then
        echo "celery>=5.2.0" >> requirements.txt
    fi
    
    # Frontend
    if [ ${LIBRARIES["pandas"]} -eq 1 ]; then
        echo "pandas>=2.0.0" >> requirements.txt
    fi
    
    if [ ${LIBRARIES["numpy"]} -eq 1 ]; then
        echo "numpy>=1.24.0" >> requirements.txt
    fi
    
    if [ ${LIBRARIES["matplotlib"]} -eq 1 ]; then
        echo "matplotlib>=3.7.0" >> requirements.txt
    fi
    
    if [ ${LIBRARIES["requests"]} -eq 1 ]; then
        echo "requests>=2.31.0" >> requirements.txt
    fi
    
    if [ ${LIBRARIES["pillow"]} -eq 1 ]; then
        echo "Pillow>=10.0.0" >> requirements.txt
    fi
    
    if [ ${LIBRARIES["pyjwt"]} -eq 1 ]; then
        echo "PyJWT>=2.8.0" >> requirements.txt
    fi
    
    # Testing
    if [ ${LIBRARIES["pytest"]} -eq 1 ]; then
        echo "pytest>=7.3.0" >> requirements.txt
        echo "pytest-flask>=1.2.0" >> requirements.txt
    fi
    
    if [ ${LIBRARIES["coverage"]} -eq 1 ]; then
        echo "coverage>=7.2.0" >> requirements.txt
    fi
    
    if [ ${LIBRARIES["faker"]} -eq 1 ]; then
        echo "Faker>=18.0.0" >> requirements.txt
    fi
    
    # Deployment
    if [ ${LIBRARIES["gunicorn"]} -eq 1 ]; then
        echo "gunicorn>=20.1.0" >> requirements.txt
    fi
    
    if [ ${LIBRARIES["whitenoise"]} -eq 1 ]; then
        echo "whitenoise>=6.4.0" >> requirements.txt
    fi
    
    if [ ${LIBRARIES["sentry_sdk"]} -eq 1 ]; then
        echo "sentry-sdk>=1.25.0" >> requirements.txt
    fi
    
    # .env.example
    cat > .env.example << EOF
# Flask Configuration
FLASK_APP=run.py
FLASK_ENV=development
FLASK_DEBUG=1
SECRET_KEY=change-this-to-a-very-secret-key-in-production

# Database Configuration
DATABASE_URL=sqlite:///app.db
# DATABASE_URL=postgresql://user:password@localhost/dbname
# DATABASE_URL=mysql://user:password@localhost/dbname

# Redis Configuration (if using)
REDIS_URL=redis://localhost:6379/0

# Email Configuration
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USE_TLS=1
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-password

# API Configuration
API_TITLE=${PROJECT_NAME} API
API_VERSION=1.0.0

# Security
JWT_SECRET_KEY=your-jwt-secret-key-change-in-production
CORS_ORIGINS=http://localhost:3000,http://localhost:5000

# File Uploads
MAX_CONTENT_LENGTH=16777216  # 16MB
UPLOAD_FOLDER=app/static/uploads
ALLOWED_EXTENSIONS=pdf,png,jpg,jpeg,gif

# External APIs
GOOGLE_MAPS_API_KEY=your-google-maps-api-key
STRIPE_SECRET_KEY=your-stripe-secret-key

# Application Settings
APP_NAME="${PROJECT_NAME}"
APP_VERSION="1.0.0"
APP_DESCRIPTION="A Flask application generated with ${GENERATOR_NAME}"
EOF

    # .gitignore
    cat > .gitignore << EOF
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Virtual Environment
venv/
env/
ENV/
.env
.venv

# Database
*.db
*.sqlite3
instance/
migrations/versions/

# Logs
logs/
*.log

# Uploads
app/static/uploads/*
!app/static/uploads/.gitkeep

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Testing
.coverage
htmlcov/
.pytest_cache/
.tox/

# Production
*.pyc
*.pyo
*.pyd
.cache

# Jupyter Notebook
.ipynb_checkpoints

# Environment variables
.env.local
.env.development.local
.env.test.local
.env.production.local
EOF

    print_success "Archivos de configuración creados"
}

create_python_files() {
    print_step "Creando archivos Python..."
    
    # app/__init__.py
    cat > app/__init__.py << EOF
"""
${PROJECT_NAME} - A Flask Application
Generated with ${GENERATOR_NAME} by ${AUTHOR_NAME}
GitHub: ${AUTHOR_GITHUB}
"""

from flask import Flask, render_template
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_login import LoginManager
from flask_wtf.csrf import CSRFProtect
from flask_mail import Mail
from flask_restx import Api
from flask_socketio import SocketIO
from flask_babel import Babel
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from config.config import Config
import os

# Initialize extensions
db = SQLAlchemy()
migrate = Migrate()
login_manager = LoginManager()
csrf = CSRFProtect()
mail = Mail()
socketio = SocketIO()
babel = Babel()
limiter = Limiter(key_func=get_remote_address, default_limits=["200 per day", "50 per hour"])

def create_app(config_class=Config):
    """Application factory pattern"""
    app = Flask(__name__)
    app.config.from_object(config_class)
    
    # Initialize extensions with app
    db.init_app(app)
    migrate.init_app(app, db)
    login_manager.init_app(app)
    csrf.init_app(app)
    mail.init_app(app)
    socketio.init_app(app, cors_allowed_origins="*")
    babel.init_app(app)
    limiter.init_app(app)
    
    # Configure login manager
    login_manager.login_view = 'auth.login'
    login_manager.login_message_category = 'info'
    login_manager.refresh_view = 'auth.refresh'
    
    # Register blueprints
    from app.routes.main import main_bp
    from app.routes.auth import auth_bp
    from app.routes.api import api_bp
    from app.routes.admin import admin_bp
    
    app.register_blueprint(main_bp)
    app.register_blueprint(auth_bp, url_prefix='/auth')
    app.register_blueprint(api_bp, url_prefix='/api/v1')
    app.register_blueprint(admin_bp, url_prefix='/admin')
    
    # Create database tables
    with app.app_context():
        db.create_all()
    
    # Error handlers
    @app.errorhandler(404)
    def not_found_error(error):
        return render_template('errors/404.html'), 404
    
    @app.errorhandler(500)
    def internal_error(error):
        return render_template('errors/500.html'), 500
    
    @app.errorhandler(403)
    def forbidden_error(error):
        return render_template('errors/403.html'), 403
    
    # Shell context
    @app.shell_context_processor
    def make_shell_context():
        return {
            'db': db,
            'User': app.models.User,
            'Post': app.models.Post
        }
    
    return app
EOF

    # config/config.py
    cat > app/config/config.py << EOF
import os
from datetime import timedelta
from dotenv import load_dotenv

load_dotenv()

class Config:
    # Basic Flask Config
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'dev-secret-key-change-in-production'
    
    # Database
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or 'sqlite:///app.db'
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_ENGINE_OPTIONS = {
        'pool_recycle': 300,
        'pool_pre_ping': True,
    }
    
    # Security
    SESSION_COOKIE_SECURE = os.environ.get('FLASK_ENV') == 'production'
    SESSION_COOKIE_HTTPONLY = True
    SESSION_COOKIE_SAMESITE = 'Lax'
    REMEMBER_COOKIE_SECURE = True
    REMEMBER_COOKIE_HTTPONLY = True
    
    # File Uploads
    MAX_CONTENT_LENGTH = int(os.environ.get('MAX_CONTENT_LENGTH', 16 * 1024 * 1024))  # 16MB
    UPLOAD_FOLDER = os.environ.get('UPLOAD_FOLDER', 'app/static/uploads')
    ALLOWED_EXTENSIONS = {'pdf', 'png', 'jpg', 'jpeg', 'gif'}
    
    # Email
    MAIL_SERVER = os.environ.get('MAIL_SERVER', 'smtp.gmail.com')
    MAIL_PORT = int(os.environ.get('MAIL_PORT', 587))
    MAIL_USE_TLS = os.environ.get('MAIL_USE_TLS', 'True').lower() in ('true', '1', 't')
    MAIL_USERNAME = os.environ.get('MAIL_USERNAME')
    MAIL_PASSWORD = os.environ.get('MAIL_PASSWORD')
    MAIL_DEFAULT_SENDER = os.environ.get('MAIL_DEFAULT_SENDER', 'noreply@example.com')
    
    # JWT
    JWT_SECRET_KEY = os.environ.get('JWT_SECRET_KEY') or SECRET_KEY
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(hours=1)
    JWT_REFRESH_TOKEN_EXPIRES = timedelta(days=30)
    JWT_TOKEN_LOCATION = ['headers', 'cookies']
    JWT_COOKIE_SECURE = os.environ.get('FLASK_ENV') == 'production'
    
    # CORS
    CORS_ORIGINS = os.environ.get('CORS_ORIGINS', 'http://localhost:3000,http://localhost:5000').split(',')
    
    # Redis
    REDIS_URL = os.environ.get('REDIS_URL', 'redis://localhost:6379/0')
    
    # Celery
    CELERY_BROKER_URL = os.environ.get('CELERY_BROKER_URL', REDIS_URL)
    CELERY_RESULT_BACKEND = os.environ.get('CELERY_RESULT_BACKEND', REDIS_URL)
    
    # API
    API_TITLE = os.environ.get('API_TITLE', '${PROJECT_NAME} API')
    API_VERSION = os.environ.get('API_VERSION', '1.0.0')
    API_DOC = '/api/docs'
    OPENAPI_VERSION = '3.0.2'
    OPENAPI_URL_PREFIX = '/api'
    OPENAPI_SWAGGER_UI_PATH = '/docs'
    OPENAPI_SWAGGER_UI_URL = 'https://cdn.jsdelivr.net/npm/swagger-ui-dist/'
    
    # Application
    APP_NAME = os.environ.get('APP_NAME', '${PROJECT_NAME}')
    APP_VERSION = os.environ.get('APP_VERSION', '1.0.0')
    APP_DESCRIPTION = os.environ.get('APP_DESCRIPTION', 'A Flask application generated with ${GENERATOR_NAME}')
    
    # Logging
    LOG_LEVEL = os.environ.get('LOG_LEVEL', 'INFO')
    LOG_FORMAT = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    
    @staticmethod
    def init_app(app):
        pass

class DevelopmentConfig(Config):
    DEBUG = True
    SQLALCHEMY_ECHO = True
    EXPLAIN_TEMPLATE_LOADING = False

class TestingConfig(Config):
    TESTING = True
    DEBUG = True
    SQLALCHEMY_DATABASE_URI = 'sqlite:///:memory:'
    WTF_CSRF_ENABLED = False
    PRESERVE_CONTEXT_ON_EXCEPTION = False

class ProductionConfig(Config):
    DEBUG = False
    TESTING = False
    SQLALCHEMY_ENGINE_OPTIONS = {
        'pool_size': 10,
        'max_overflow': 20,
        'pool_recycle': 3600,
        'pool_pre_ping': True,
    }
    
    @classmethod
    def init_app(cls, app):
        Config.init_app(app)
        
        # Email errors to administrators
        import logging
        from logging.handlers import SMTPHandler
        
        credentials = None
        secure = None
        
        if app.config.get('MAIL_USERNAME'):
            credentials = (app.config['MAIL_USERNAME'], app.config['MAIL_PASSWORD'])
            if app.config['MAIL_USE_TLS']:
                secure = ()
        
        mail_handler = SMTPHandler(
            mailhost=(app.config['MAIL_SERVER'], app.config['MAIL_PORT']),
            fromaddr=app.config['MAIL_DEFAULT_SENDER'],
            toaddrs=app.config.get('ADMINS', []),
            subject='${PROJECT_NAME} Application Error',
            credentials=credentials,
            secure=secure
        )
        mail_handler.setLevel(logging.ERROR)
        app.logger.addHandler(mail_handler)

config = {
    'development': DevelopmentConfig,
    'testing': TestingConfig,
    'production': ProductionConfig,
    'default': DevelopmentConfig
}
EOF

    # run.py
    cat > run.py << EOF
#!/usr/bin/env python3
"""
Entry point for ${PROJECT_NAME} application
Generated with ${GENERATOR_NAME} by ${AUTHOR_NAME}
"""

import os
from app import create_app, socketio
from app.config.config import config

# Determine environment
env = os.environ.get('FLASK_ENV', 'development')
app = create_app(config[env])

if __name__ == '__main__':
    host = os.environ.get('FLASK_HOST', '127.0.0.1')
    port = int(os.environ.get('FLASK_PORT', 5000))
    
    if env == 'development':
        app.run(host=host, port=port, debug=True)
    else:
        socketio.run(app, host=host, port=port, debug=False)
EOF

    # wsgi.py
    cat > wsgi.py << EOF
"""
WSGI entry point for production
"""
import os
from app import create_app, socketio
from app.config.config import ProductionConfig

app = create_app(ProductionConfig)

if __name__ == "__main__":
    socketio.run(app)
EOF

    print_success "Archivos Python creados"
}

create_templates() {
    print_step "Creando plantillas HTML..."
    
    # Crear directorios de templates
    mkdir -p app/templates/{auth,admin,errors,email,includes}
    
    # base.html con créditos
    cat > app/templates/base.html << EOF
<!DOCTYPE html>
<html lang="es" data-bs-theme="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{% block title %}{{ title }}{% endblock %} - {{ config.APP_NAME }}</title>
    
    <!-- Meta Tags -->
    <meta name="description" content="{{ config.APP_DESCRIPTION }}">
    <meta name="author" content="${AUTHOR_NAME}">
    <meta name="generator" content="${GENERATOR_NAME}">
    
    <!-- Favicon -->
    <link rel="icon" href="{{ url_for('static', filename='images/favicon.ico') }}">
    
    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- Custom CSS -->
    <link rel="stylesheet" href="{{ url_for('static', filename='css/main.css') }}">
    
    {% block extra_css %}{% endblock %}
    
    <!-- CSRF Token -->
    <meta name="csrf-token" content="{{ csrf_token() }}">
</head>
<body>
    <!-- Navigation -->
    {% include 'includes/navbar.html' %}
    
    <!-- Flash Messages -->
    <div class="container mt-3">
        {% with messages = get_flashed_messages(with_categories=true) %}
            {% if messages %}
                {% for category, message in messages %}
                    <div class="alert alert-{{ category if category != 'message' else 'info' }} alert-dismissible fade show" role="alert">
                        {{ message }}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                {% endfor %}
            {% endif %}
        {% endwith %}
    </div>
    
    <!-- Main Content -->
    <main class="container py-4">
        {% block content %}{% endblock %}
    </main>
    
    <!-- Footer -->
    {% include 'includes/footer.html' %}
    
    <!-- JavaScript Libraries -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    {% if config.USE_JQUERY %}
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    {% endif %}
    
    {% if config.USE_ALPINEJS %}
    <script defer src="https://unpkg.com/alpinejs@3.x.x/dist/cdn.min.js"></script>
    {% endif %}
    
    {% if config.USE_AXIOS %}
    <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
    {% endif %}
    
    <!-- Custom JavaScript -->
    <script src="{{ url_for('static', filename='js/main.js') }}"></script>
    
    {% block extra_js %}{% endblock %}
    
    <!-- Footer Credits -->
    <div class="text-center mt-5 text-muted small">
        <p>
            Generado con <i class="fas fa-heart text-danger"></i> usando 
            <a href="${AUTHOR_GITHUB}" target="_blank" class="text-decoration-none">${GENERATOR_NAME}</a> 
            por <a href="${AUTHOR_GITHUB}" target="_blank" class="text-decoration-none">${AUTHOR_NAME}</a>
        </p>
    </div>
</body>
</html>
EOF

    # navbar.html
    cat > app/templates/includes/navbar.html << EOF
<nav class="navbar navbar-expand-lg navbar-dark bg-dark shadow">
    <div class="container">
        <a class="navbar-brand" href="{{ url_for('main.index') }}">
            <i class="fas fa-rocket me-2"></i>{{ config.APP_NAME }}
        </a>
        
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav me-auto">
                <li class="nav-item">
                    <a class="nav-link {{ 'active' if request.endpoint == 'main.index' }}" 
                       href="{{ url_for('main.index') }}">
                        <i class="fas fa-home"></i> Inicio
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link {{ 'active' if request.endpoint == 'main.about' }}" 
                       href="{{ url_for('main.about') }}">
                        <i class="fas fa-info-circle"></i> Acerca de
                    </a>
                </li>
                
                {% if current_user.is_authenticated %}
                <li class="nav-item">
                    <a class="nav-link {{ 'active' if request.endpoint == 'main.dashboard' }}" 
                       href="{{ url_for('main.dashboard') }}">
                        <i class="fas fa-tachometer-alt"></i> Dashboard
                    </a>
                </li>
                {% endif %}
                
                {% if current_user.is_admin %}
                <li class="nav-item">
                    <a class="nav-link {{ 'active' if request.endpoint == 'admin.index' }}" 
                       href="{{ url_for('admin.index') }}">
                        <i class="fas fa-cog"></i> Admin
                    </a>
                </li>
                {% endif %}
            </ul>
            
            <ul class="navbar-nav">
                {% if current_user.is_authenticated %}
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">
                            <i class="fas fa-user-circle"></i> {{ current_user.username }}
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end">
                            <li><a class="dropdown-item" href="{{ url_for('auth.profile') }}">
                                <i class="fas fa-user"></i> Perfil
                            </a></li>
                            <li><a class="dropdown-item" href="{{ url_for('auth.settings') }}">
                                <i class="fas fa-cog"></i> Configuración
                            </a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item" href="{{ url_for('auth.logout') }}">
                                <i class="fas fa-sign-out-alt"></i> Cerrar Sesión
                            </a></li>
                        </ul>
                    </li>
                {% else %}
                    <li class="nav-item">
                        <a class="nav-link {{ 'active' if request.endpoint == 'auth.login' }}" 
                           href="{{ url_for('auth.login') }}">
                            <i class="fas fa-sign-in-alt"></i> Iniciar Sesión
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link {{ 'active' if request.endpoint == 'auth.register' }}" 
                           href="{{ url_for('auth.register') }}">
                            <i class="fas fa-user-plus"></i> Registrarse
                        </a>
                    </li>
                {% endif %}
            </ul>
        </div>
    </div>
</nav>
EOF

    # footer.html con créditos
    cat > app/templates/includes/footer.html << EOF
<footer class="footer mt-auto py-4 bg-dark text-light">
    <div class="container">
        <div class="row">
            <div class="col-md-4">
                <h5>{{ config.APP_NAME }}</h5>
                <p class="text-muted">
                    {{ config.APP_DESCRIPTION }}
                </p>
                <p class="text-muted small">
                    <i class="fas fa-code-branch"></i> Versión {{ config.APP_VERSION }}
                </p>
            </div>
            
            <div class="col-md-4">
                <h5>Enlaces Rápidos</h5>
                <ul class="list-unstyled">
                    <li><a href="{{ url_for('main.index') }}" class="text-light text-decoration-none">Inicio</a></li>
                    <li><a href="{{ url_for('main.about') }}" class="text-light text-decoration-none">Acerca de</a></li>
                    <li><a href="{{ url_for('main.contact') }}" class="text-light text-decoration-none">Contacto</a></li>
                    <li><a href="/api/docs" class="text-light text-decoration-none">API Docs</a></li>
                </ul>
            </div>
            
            <div class="col-md-4">
                <h5>Tecnologías</h5>
                <div class="tech-stack">
                    <span class="badge bg-primary me-1 mb-1">Flask</span>
                    <span class="badge bg-success me-1 mb-1">Python</span>
                    <span class="badge bg-info me-1 mb-1">Bootstrap</span>
                    <span class="badge bg-warning me-1 mb-1">JavaScript</span>
                    <span class="badge bg-danger me-1 mb-1">SQLAlchemy</span>
                </div>
                
                <div class="mt-3">
                    <p class="text-muted small">
                        <i class="fas fa-tools"></i> Generado con ${GENERATOR_NAME}
                    </p>
                </div>
            </div>
        </div>
        
        <hr class="text-muted">
        
        <div class="row">
            <div class="col-md-6">
                <p class="mb-0 text-muted">
                    &copy; {{ now.year }} {{ config.APP_NAME }}. Todos los derechos reservados.
                </p>
            </div>
            <div class="col-md-6 text-md-end">
                <p class="mb-0 text-muted">
                    Creado por 
                    <a href="${AUTHOR_GITHUB}" target="_blank" class="text-decoration-none">
                        ${AUTHOR_NAME}
                    </a> | 
                    <a href="#" class="text-decoration-none">Política de Privacidad</a> | 
                    <a href="#" class="text-decoration-none">Términos de Servicio</a>
                </p>
            </div>
        </div>
    </div>
</footer>
EOF

    # index.html
    cat > app/templates/index.html << EOF
{% extends "base.html" %}

{% block title %}Inicio{% endblock %}

{% block content %}
<div class="hero-section text-center py-5 mb-5 bg-primary text-white rounded">
    <div class="container">
        <h1 class="display-4 fw-bold mb-3">
            <i class="fas fa-rocket me-2"></i>Bienvenido a {{ config.APP_NAME }}
        </h1>
        <p class="lead mb-4">
            Una aplicación Flask moderna, escalable y lista para producción.
            Generada automáticamente con las mejores prácticas y tecnologías actuales.
        </p>
        <div class="d-grid gap-2 d-md-flex justify-content-md-center">
            {% if not current_user.is_authenticated %}
                <a href="{{ url_for('auth.register') }}" class="btn btn-light btn-lg px-4 me-md-2">
                    <i class="fas fa-user-plus me-2"></i>Comenzar Gratis
                </a>
                <a href="{{ url_for('auth.login') }}" class="btn btn-outline-light btn-lg px-4">
                    <i class="fas fa-sign-in-alt me-2"></i>Iniciar Sesión
                </a>
            {% else %}
                <a href="{{ url_for('main.dashboard') }}" class="btn btn-light btn-lg px-4 me-md-2">
                    <i class="fas fa-tachometer-alt me-2"></i>Ir al Dashboard
                </a>
                <a href="{{ url_for('main.profile') }}" class="btn btn-outline-light btn-lg px-4">
                    <i class="fas fa-user me-2"></i>Mi Perfil
                </a>
            {% endif %}
        </div>
    </div>
</div>

<div class="container">
    <div class="row mb-5">
        <div class="col-lg-8 mx-auto text-center">
            <h2 class="mb-4">
                <i class="fas fa-star text-warning me-2"></i>Características Principales
            </h2>
            <p class="lead text-muted">
                Esta aplicación incluye todo lo necesario para construir proyectos web profesionales.
            </p>
        </div>
    </div>
    
    <div class="row g-4">
        <!-- Feature Cards -->
        <div class="col-md-4">
            <div class="card h-100 border-0 shadow-sm">
                <div class="card-body text-center p-4">
                    <div class="feature-icon mb-3">
                        <i class="fas fa-shield-alt fa-3x text-primary"></i>
                    </div>
                    <h4 class="card-title">Seguridad Avanzada</h4>
                    <p class="card-text text-muted">
                        Autenticación JWT, protección CSRF, hashing de contraseñas,
                        rate limiting y más.
                    </p>
                    <ul class="list-unstyled text-start">
                        <li><i class="fas fa-check text-success me-2"></i>Flask-Login</li>
                        <li><i class="fas fa-check text-success me-2"></i>JWT Tokens</li>
                        <li><i class="fas fa-check text-success me-2"></i>Flask-Limiter</li>
                    </ul>
                </div>
            </div>
        </div>
        
        <div class="col-md-4">
            <div class="card h-100 border-0 shadow-sm">
                <div class="card-body text-center p-4">
                    <div class="feature-icon mb-3">
                        <i class="fas fa-database fa-3x text-success"></i>
                    </div>
                    <h4 class="card-title">Base de Datos</h4>
                    <p class="card-text text-muted">
                        Soporte para múltiples bases de datos con migraciones
                        y modelos optimizados.
                    </p>
                    <ul class="list-unstyled text-start">
                        <li><i class="fas fa-check text-success me-2"></i>SQLAlchemy ORM</li>
                        <li><i class="fas fa-check text-success me-2"></i>Flask-Migrate</li>
                        <li><i class="fas fa-check text-success me-2"></i>PostgreSQL/MySQL</li>
                    </ul>
                </div>
            </div>
        </div>
        
        <div class="col-md-4">
            <div class="card h-100 border-0 shadow-sm">
                <div class="card-body text-center p-4">
                    <div class="feature-icon mb-3">
                        <i class="fas fa-bolt fa-3x text-warning"></i>
                    </div>
                    <h4 class="card-title">API REST</h4>
                    <p class="card-text text-muted">
                        API completa con documentación automática,
                        validación y autenticación.
                    </p>
                    <ul class="list-unstyled text-start">
                        <li><i class="fas fa-check text-success me-2"></i>Flask-RESTx</li>
                        <li><i class="fas fa-check text-success me-2"></i>Swagger UI</li>
                        <li><i class="fas fa-check text-success me-2"></i>WebSocket</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Generator Info -->
    <div class="row mt-5">
        <div class="col-lg-8 mx-auto">
            <div class="card border-primary">
                <div class="card-header bg-primary text-white">
                    <h5 class="mb-0">
                        <i class="fas fa-info-circle me-2"></i>Información del Generador
                    </h5>
                </div>
                <div class="card-body">
                    <p>
                        Esta aplicación fue generada automáticamente usando 
                        <strong>${GENERATOR_NAME}</strong>, una herramienta creada por 
                        <a href="${AUTHOR_GITHUB}" target="_blank" class="text-decoration-none">${AUTHOR_NAME}</a> 
                        para simplificar el desarrollo de aplicaciones Flask.
                    </p>
                    <div class="row">
                        <div class="col-md-6">
                            <h6>Características incluidas:</h6>
                            <ul>
                                <li>Arquitectura modular con Blueprints</li>
                                <li>Sistema de autenticación completo</li>
                                <li>API REST con documentación Swagger</li>
                                <li>Frontend con Bootstrap 5</li>
                                <li>Configuración para Docker</li>
                            </ul>
                        </div>
                        <div class="col-md-6">
                            <h6>Enlaces útiles:</h6>
                            <ul class="list-unstyled">
                                <li>
                                    <a href="${AUTHOR_GITHUB}" target="_blank" class="text-decoration-none">
                                        <i class="fab fa-github me-2"></i>GitHub del Autor
                                    </a>
                                </li>
                                <li>
                                    <a href="/api/docs" class="text-decoration-none">
                                        <i class="fas fa-book me-2"></i>Documentación API
                                    </a>
                                </li>
                                <li>
                                    <a href="{{ url_for('main.about') }}" class="text-decoration-none">
                                        <i class="fas fa-info-circle me-2"></i>Acerca de este Proyecto
                                    </a>
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
{% endblock %}
EOF

    print_success "Plantillas HTML creadas"
}

create_static_files() {
    print_step "Creando archivos estáticos..."
    
    # CSS principal
    cat > app/static/css/main.css << EOF
/* ============================================
   ${PROJECT_NAME} - Main Stylesheet
   Generated with ${GENERATOR_NAME} by ${AUTHOR_NAME}
   ============================================ */

:root {
    --primary-color: #4e73df;
    --secondary-color: #858796;
    --success-color: #1cc88a;
    --info-color: #36b9cc;
    --warning-color: #f6c23e;
    --danger-color: #e74a3b;
    --light-color: #f8f9fc;
    --dark-color: #5a5c69;
    --gray-100: #f8f9fa;
    --gray-200: #e9ecef;
    --gray-300: #dee2e6;
    --gray-400: #ced4da;
    --gray-500: #adb5bd;
    --gray-600: #6c757d;
    --gray-700: #495057;
    --gray-800: #343a40;
    --gray-900: #212529;
    
    --border-radius: 0.35rem;
    --box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15);
    --transition: all 0.3s ease;
}

/* Base Styles */
body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background-color: var(--light-color);
    color: var(--gray-800);
    min-height: 100vh;
    display: flex;
    flex-direction: column;
}

main {
    flex: 1;
}

/* Typography */
h1, h2, h3, h4, h5, h6 {
    font-weight: 600;
    color: var(--dark-color);
}

.display-1, .display-2, .display-3, .display-4 {
    font-weight: 700;
}

/* Navigation */
.navbar {
    box-shadow: var(--box-shadow);
}

.navbar-brand {
    font-weight: 700;
    font-size: 1.5rem;
}

/* Cards */
.card {
    border: 1px solid var(--gray-300);
    border-radius: var(--border-radius);
    box-shadow: var(--box-shadow);
    transition: var(--transition);
}

.card:hover {
    transform: translateY(-5px);
    box-shadow: 0 0.5rem 2rem 0 rgba(58, 59, 69, 0.2);
}

.card-header {
    border-bottom: 1px solid var(--gray-300);
    background-color: var(--light-color);
    font-weight: 600;
}

/* Buttons */
.btn {
    border-radius: var(--border-radius);
    font-weight: 500;
    transition: var(--transition);
}

.btn-primary {
    background-color: var(--primary-color);
    border-color: var(--primary-color);
}

.btn-primary:hover {
    background-color: #2e59d9;
    border-color: #2e59d9;
    transform: translateY(-1px);
}

.btn-lg {
    padding: 0.75rem 1.5rem;
    font-size: 1.1rem;
}

/* Forms */
.form-control {
    border-radius: var(--border-radius);
    border: 1px solid var(--gray-400);
    padding: 0.75rem 1rem;
    transition: var(--transition);
}

.form-control:focus {
    border-color: var(--primary-color);
    box-shadow: 0 0 0 0.2rem rgba(78, 115, 223, 0.25);
}

.input-group-text {
    background-color: var(--light-color);
    border: 1px solid var(--gray-400);
    color: var(--gray-600);
}

/* Alerts */
.alert {
    border-radius: var(--border-radius);
    border: none;
    box-shadow: var(--box-shadow);
}

.alert-dismissible .btn-close {
    padding: 1rem;
}

/* Tables */
.table {
    border-radius: var(--border-radius);
    overflow: hidden;
}

.table thead th {
    border-bottom: 2px solid var(--gray-300);
    background-color: var(--light-color);
}

/* Badges */
.badge {
    font-weight: 500;
    padding: 0.35em 0.65em;
}

/* Footer */
.footer {
    border-top: 1px solid var(--gray-300);
    margin-top: auto;
}

/* Hero Section */
.hero-section {
    background: linear-gradient(135deg, var(--primary-color) 0%, #2e59d9 100%);
}

/* Feature Icons */
.feature-icon {
    width: 80px;
    height: 80px;
    background-color: rgba(78, 115, 223, 0.1);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto 1.5rem;
}

/* Dashboard */
.stat-card {
    border-left: 0.25rem solid !important;
    transition: var(--transition);
}

.stat-card:hover {
    transform: translateY(-3px);
}

/* Animations */
@keyframes fadeIn {
    from {
        opacity: 0;
        transform: translateY(20px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

.fade-in {
    animation: fadeIn 0.5s ease-out;
}

/* Loading Spinner */
.spinner-container {
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 200px;
}

.spinner {
    width: 3rem;
    height: 3rem;
    border: 0.25rem solid var(--gray-300);
    border-top: 0.25rem solid var(--primary-color);
    border-radius: 50%;
    animation: spin 1s linear infinite;
}

@keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
}

/* Custom Scrollbar */
::-webkit-scrollbar {
    width: 10px;
}

::-webkit-scrollbar-track {
    background: var(--gray-200);
}

::-webkit-scrollbar-thumb {
    background: var(--primary-color);
    border-radius: 5px;
}

::-webkit-scrollbar-thumb:hover {
    background: #2e59d9;
}

/* Responsive */
@media (max-width: 768px) {
    .display-4 {
        font-size: 2.5rem;
    }
    
    .btn-lg {
        width: 100%;
        margin-bottom: 0.5rem;
    }
    
    .card {
        margin-bottom: 1rem;
    }
    
    .hero-section {
        padding: 2rem 1rem !important;
    }
}

/* Utility Classes */
.text-primary { color: var(--primary-color) !important; }
.bg-primary { background-color: var(--primary-color) !important; }
.border-primary { border-color: var(--primary-color) !important; }

.text-secondary { color: var(--secondary-color) !important; }
.bg-secondary { background-color: var(--secondary-color) !important; }

.text-success { color: var(--success-color) !important; }
.bg-success { background-color: var(--success-color) !important; }

.text-warning { color: var(--warning-color) !important; }
.bg-warning { background-color: var(--warning-color) !important; }

.text-danger { color: var(--danger-color) !important; }
.bg-danger { background-color: var(--danger-color) !important; }

/* Generator Credit */
.generator-credit {
    font-size: 0.85rem;
    opacity: 0.8;
}

.generator-credit a {
    color: inherit;
    text-decoration: none;
    transition: opacity 0.3s;
}

.generator-credit a:hover {
    opacity: 0.9;
    text-decoration: underline;
}
EOF

    # JavaScript principal
    cat > app/static/js/main.js << EOF
// ============================================
// ${PROJECT_NAME} - Main JavaScript
// Generated with ${GENERATOR_NAME} by ${AUTHOR_NAME}
// ============================================

document.addEventListener('DOMContentLoaded', function() {
    console.log('${PROJECT_NAME} - JavaScript loaded');
    
    // Initialize components
    initBootstrapComponents();
    setupCSRF();
    setupFormValidation();
    setupAutoDismissAlerts();
    setupDashboardComponents();
    setupAJAXForms();
    setupFileUploads();
    setupNotifications();
    
    // Generator credit
    console.log('Generated with ${GENERATOR_NAME} by ${AUTHOR_NAME}');
});

// ============================================
// INITIALIZATION FUNCTIONS
// ============================================

function initBootstrapComponents() {
    // Tooltips
    const tooltipTriggerList = [].slice.call(
        document.querySelectorAll('[data-bs-toggle="tooltip"]')
    );
    tooltipTriggerList.map(function(tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl);
    });
    
    // Popovers
    const popoverTriggerList = [].slice.call(
        document.querySelectorAll('[data-bs-toggle="popover"]')
    );
    popoverTriggerList.map(function(popoverTriggerEl) {
        return new bootstrap.Popover(popoverTriggerEl);
    });
    
    // Toasts
    const toastElList = [].slice.call(document.querySelectorAll('.toast'));
    const toastList = toastElList.map(function(toastEl) {
        return new bootstrap.Toast(toastEl, { autohide: true, delay: 5000 });
    });
}

function setupCSRF() {
    // Get CSRF token from meta tag
    const csrfToken = document.querySelector('meta[name="csrf-token"]');
    if (!csrfToken) return;
    
    // Setup for Fetch API
    const originalFetch = window.fetch;
    window.fetch = function(url, options = {}) {
        if (!/^(GET|HEAD|OPTIONS|TRACE)$/i.test(options.method || 'GET')) {
            options.headers = {
                ...options.headers,
                'X-CSRFToken': csrfToken.content
            };
        }
        return originalFetch(url, options);
    };
    
    // Setup for Axios (if available)
    if (typeof axios !== 'undefined') {
        axios.defaults.headers.common['X-CSRFToken'] = csrfToken.content;
    }
}

function setupFormValidation() {
    const forms = document.querySelectorAll('.needs-validation');
    
    Array.from(forms).forEach(form => {
        form.addEventListener('submit', event => {
            if (!form.checkValidity()) {
                event.preventDefault();
                event.stopPropagation();
            }
            
            form.classList.add('was-validated');
        }, false);
    });
}

function setupAutoDismissAlerts() {
    const alerts = document.querySelectorAll('.alert:not(.alert-permanent)');
    alerts.forEach(alert => {
        setTimeout(() => {
            if (alert && alert.parentNode) {
                const bsAlert = new bootstrap.Alert(alert);
                bsAlert.close();
            }
        }, 5000);
    });
}

function setupDashboardComponents() {
    if (!document.querySelector('[data-page="dashboard"]')) return;
    
    // Load dashboard stats
    loadDashboardStats();
    
    // Update every 30 seconds
    setInterval(loadDashboardStats, 30000);
    
    // Setup charts if Chart.js is available
    if (typeof Chart !== 'undefined') {
        setupCharts();
    }
}

function setupAJAXForms() {
    document.addEventListener('submit', function(e) {
        const form = e.target;
        if (!form.classList.contains('ajax-form')) return;
        
        e.preventDefault();
        
        const formData = new FormData(form);
        const action = form.getAttribute('action') || window.location.href;
        const method = form.getAttribute('method') || 'POST';
        
        fetch(action, {
            method: method,
            body: formData,
            headers: {
                'X-Requested-With': 'XMLHttpRequest'
            }
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                showToast(data.message || 'Operación exitosa', 'success');
                if (data.redirect) {
                    setTimeout(() => {
                        window.location.href = data.redirect;
                    }, 1500);
                }
            } else {
                showToast(data.message || 'Error en la operación', 'danger');
            }
        })
        .catch(error => {
            console.error('Error:', error);
            showToast('Error en la solicitud', 'danger');
        });
    });
}

function setupFileUploads() {
    const fileInputs = document.querySelectorAll('input[type="file"][data-preview]');
    
    fileInputs.forEach(input => {
        const previewId = input.getAttribute('data-preview');
        const preview = document.getElementById(previewId);
        
        if (!preview) return;
        
        input.addEventListener('change', function() {
            const file = this.files[0];
            if (!file) return;
            
            // Validate file type
            const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'application/pdf'];
            if (!allowedTypes.includes(file.type)) {
                showToast('Tipo de archivo no permitido', 'warning');
                this.value = '';
                return;
            }
            
            // Validate file size (5MB max)
            if (file.size > 5 * 1024 * 1024) {
                showToast('El archivo debe ser menor a 5MB', 'warning');
                this.value = '';
                return;
            }
            
            // Show preview for images
            if (file.type.startsWith('image/')) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    preview.src = e.target.result;
                    preview.style.display = 'block';
                };
                reader.readAsDataURL(file);
            }
        });
    });
}

function setupNotifications() {
    # Check for browser notifications permission
    if ('Notification' in window && Notification.permission === 'default') {
        Notification.requestPermission();
    }
}

# ============================================
# UTILITY FUNCTIONS
# ============================================

function showToast(message, type = 'info', duration = 5000) {
    const toastContainer = document.getElementById('toast-container') || createToastContainer();
    const toastId = 'toast-' + Date.now();
    
    const icons = {
        success: 'check-circle',
        danger: 'exclamation-circle',
        warning: 'exclamation-triangle',
        info: 'info-circle'
    };
    
    const toastHTML = \`
        <div id="\${toastId}" class="toast align-items-center text-bg-\${type}" role="alert">
            <div class="d-flex">
                <div class="toast-body">
                    <i class="fas fa-\${icons[type] || 'info-circle'} me-2"></i>
                    \${message}
                </div>
                <button type="button" class="btn-close btn-close-white me-2 m-auto" 
                        data-bs-dismiss="toast"></button>
            </div>
        </div>
    \`;
    
    toastContainer.insertAdjacentHTML('beforeend', toastHTML);
    
    const toastElement = document.getElementById(toastId);
    const toast = new bootstrap.Toast(toastElement, {
        autohide: true,
        delay: duration
    });
    toast.show();
    
    toastElement.addEventListener('hidden.bs.toast', function() {
        toastElement.remove();
    });
}

function createToastContainer() {
    const container = document.createElement('div');
    container.id = 'toast-container';
    container.className = 'toast-container position-fixed bottom-0 end-0 p-3';
    container.style.zIndex = '1060';
    document.body.appendChild(container);
    return container;
}

function loadDashboardStats() {
    if (!window.API_ENDPOINTS || !API_ENDPOINTS.stats) return;
    
    fetch(API_ENDPOINTS.stats)
        .then(response => response.json())
        .then(data => updateStatsDisplay(data))
        .catch(error => console.error('Error loading stats:', error));
}

function updateStatsDisplay(stats) {
    # Update DOM elements with stats data
    # Implementation depends on your API response structure
}

function confirmAction(message, callback) {
    const modal = new bootstrap.Modal(document.getElementById('confirmationModal'));
    const modalBody = document.querySelector('#confirmationModal .modal-body');
    const confirmBtn = document.querySelector('#confirmationModal .btn-confirm');
    
    modalBody.textContent = message;
    
    const handleConfirm = () => {
        confirmBtn.removeEventListener('click', handleConfirm);
        modal.hide();
        if (typeof callback === 'function') {
            callback();
        }
    };
    
    confirmBtn.addEventListener('click', handleConfirm);
    modal.show();
}

function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('es-ES', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    });
}

function formatCurrency(amount, currency = 'USD') {
    return new Intl.NumberFormat('es-ES', {
        style: 'currency',
        currency: currency
    }).format(amount);
}

function copyToClipboard(text, showNotification = true) {
    navigator.clipboard.writeText(text).then(() => {
        if (showNotification) {
            showToast('Copiado al portapapeles', 'success');
        }
    }).catch(err => {
        console.error('Error al copiar:', err);
        showToast('Error al copiar', 'danger');
    });
}

# ============================================
# API CLIENT
# ============================================

const API = {
    async get(endpoint) {
        const response = await fetch(endpoint);
        return this.handleResponse(response);
    },
    
    async post(endpoint, data) {
        const response = await fetch(endpoint, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(data)
        });
        return this.handleResponse(response);
    },
    
    async put(endpoint, data) {
        const response = await fetch(endpoint, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(data)
        });
        return this.handleResponse(response);
    },
    
    async delete(endpoint) {
        const response = await fetch(endpoint, {
            method: 'DELETE'
        });
        return this.handleResponse(response);
    },
    
    async upload(endpoint, formData) {
        const response = await fetch(endpoint, {
            method: 'POST',
            body: formData
        });
        return this.handleResponse(response);
    },
    
    async handleResponse(response) {
        if (response.status === 204) {
            return null;
        }
        
        const contentType = response.headers.get('content-type');
        
        if (contentType && contentType.includes('application/json')) {
            const data = await response.json();
            
            if (!response.ok) {
                throw new Error(data.message || \`Error \${response.status}\`);
            }
            
            return data;
        } else {
            const text = await response.text();
            
            if (!response.ok) {
                throw new Error(text || \`Error \${response.status}\`);
            }
            
            return text;
        }
    }
};

# ============================================
# GLOBAL EXPORT
# ============================================

window.FlaskApp = {
    showToast,
    confirmAction,
    formatDate,
    formatCurrency,
    copyToClipboard,
    API,
    
    # Generator info
    generator: {
        name: '${GENERATOR_NAME}',
        author: '${AUTHOR_NAME}',
        github: '${AUTHOR_GITHUB}'
    }
};

# ============================================
# EVENT LISTENERS
# ============================================

# Copy to clipboard
document.addEventListener('click', function(e) {
    const target = e.target.closest('[data-copy]');
    if (target) {
        const text = target.getAttribute('data-copy');
        copyToClipboard(text);
    }
});

# Confirm actions
document.addEventListener('click', function(e) {
    const target = e.target.closest('[data-confirm]');
    if (target) {
        e.preventDefault();
        const message = target.getAttribute('data-confirm');
        const href = target.getAttribute('href');
        
        confirmAction(message, () => {
            if (href) {
                window.location.href = href;
            }
        });
    }
});

# Toggle dark mode
const themeToggle = document.querySelector('[data-theme-toggle]');
if (themeToggle) {
    themeToggle.addEventListener('click', function() {
        const html = document.documentElement;
        const isDark = html.getAttribute('data-bs-theme') === 'dark';
        html.setAttribute('data-bs-theme', isDark ? 'light' : 'dark');
        localStorage.setItem('theme', isDark ? 'light' : 'dark');
        showToast(\`Modo \${isDark ? 'claro' : 'oscuro'} activado\`, 'info');
    });
}

# Initialize theme from localStorage
const savedTheme = localStorage.getItem('theme');
if (savedTheme) {
    document.documentElement.setAttribute('data-bs-theme', savedTheme);
}
EOF

    print_success "Archivos estáticos creados"
}

create_additional_files() {
    print_step "Creando archivos adicionales..."
    
    # Dockerfile
    if [ $USE_DOCKER -eq 1 ]; then
        cat > Dockerfile << EOF
# ============================================
# Dockerfile for ${PROJECT_NAME}
# Generated with ${GENERATOR_NAME} by ${AUTHOR_NAME}
# ============================================

# Build stage
FROM python:3.11-slim as builder

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:\$PATH"

# Install Python dependencies
COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Production stage
FROM python:3.11-slim

# Create non-root user
RUN groupadd -r flaskgroup && useradd -r -g flaskgroup flaskuser

WORKDIR /app

# Copy virtual environment from builder
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:\$PATH"

# Copy application code
COPY . .

# Create necessary directories
RUN mkdir -p logs uploads && \
    chown -R flaskuser:flaskgroup /app

# Switch to non-root user
USER flaskuser

# Expose port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \\
    CMD curl -f http://localhost:5000/health || exit 1

# Run application
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "wsgi:app", \\
     "--workers", "4", "--threads", "2", \\
     "--timeout", "120", "--access-logfile", "-"]
EOF
    fi
    
    # docker-compose.yml
    if [ $USE_DOCKER_COMPOSE -eq 1 ]; then
        cat > docker-compose.yml << EOF
# ============================================
# Docker Compose for ${PROJECT_NAME}
# Generated with ${GENERATOR_NAME} by ${AUTHOR_NAME}
# ============================================

version: '3.8'

services:
  web:
    build: .
    ports:
      - "5000:5000"
    environment:
      - FLASK_ENV=production
      - DATABASE_URL=postgresql://postgres:password@db:5432/${PROJECT_NAME}
      - REDIS_URL=redis://redis:6379/0
    volumes:
      - ./uploads:/app/uploads
      - ./logs:/app/logs
    depends_on:
      - db
      - redis
    restart: unless-stopped
    networks:
      - ${PROJECT_NAME}-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=${PROJECT_NAME}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./scripts/db/init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - ${PROJECT_NAME}-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 30s
      timeout: 10s
      retries: 3

  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    networks:
      - ${PROJECT_NAME}-network
    restart: unless-stopped

  celery:
    build: .
    command: celery -A app.tasks.celery worker --loglevel=info
    environment:
      - FLASK_ENV=production
      - DATABASE_URL=postgresql://postgres:password@db:5432/${PROJECT_NAME}
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      - db
      - redis
    networks:
      - ${PROJECT_NAME}-network
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./docker/nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./docker/ssl:/etc/nginx/ssl
      - ./uploads:/app/uploads
    depends_on:
      - web
    networks:
      - ${PROJECT_NAME}-network
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:

networks:
  ${PROJECT_NAME}-network:
    driver: bridge
EOF
    fi
    
    # nginx.conf
    if [ $USE_NGINX -eq 1 ]; then
        mkdir -p docker/nginx
        cat > docker/nginx/nginx.conf << EOF
# ============================================
# Nginx Configuration for ${PROJECT_NAME}
# Generated with ${GENERATOR_NAME} by ${AUTHOR_NAME}
# ============================================

events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    
    # Logging
    log_format main '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                    '\$status \$body_bytes_sent "\$http_referer" '
                    '"\$http_user_agent" "\$http_x_forwarded_for"';
    
    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log warn;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript 
               application/json application/javascript application/xml+rss 
               application/atom+xml image/svg+xml;
    
    # Upstream Flask application
    upstream flask_app {
        server web:5000;
    }
    
    # HTTP server (redirect to HTTPS)
    server {
        listen 80;
        server_name _;
        return 301 https://\$host\$request_uri;
    }
    
    # HTTPS server
    server {
        listen 443 ssl http2;
        server_name localhost;
        
        # SSL certificates
        ssl_certificate /etc/nginx/ssl/certificate.crt;
        ssl_certificate_key /etc/nginx/ssl/private.key;
        
        # SSL configuration
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
        ssl_prefer_server_ciphers off;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 10m;
        
        # Security headers for HTTPS
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
        
        # Proxy to Flask application
        location / {
            proxy_pass http://flask_app;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
            proxy_set_header X-Forwarded-Host \$host;
            
            # WebSocket support
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection "upgrade";
            
            # Timeouts
            proxy_connect_timeout 60s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
        }
        
        # Static files
        location /static/ {
            alias /app/static/;
            expires 1y;
            add_header Cache-Control "public, immutable";
            access_log off;
        }
        
        # Uploads
        location /uploads/ {
            alias /app/uploads/;
            expires 1y;
            add_header Cache-Control "public, immutable";
            internal;
        }
        
        # API documentation
        location /api/docs {
            proxy_pass http://flask_app/api/docs;
            proxy_set_header Host \$host;
        }
        
        # Health check endpoint
        location /health {
            proxy_pass http://flask_app/health;
            access_log off;
        }
    }
}
EOF
    fi
    
    # Makefile
    if [ $USE_MAKEFILE -eq 1 ]; then
        cat > Makefile << EOF
# ============================================
# Makefile for ${PROJECT_NAME}
# Generated with ${GENERATOR_NAME} by ${AUTHOR_NAME}
# ============================================

.PHONY: help install test run clean db-init db-migrate db-upgrade docker-build docker-up

# Colors
RED=\\033[0;31m
GREEN=\\033[0;32m
YELLOW=\\033[1;33m
NC=\\033[0m

help: ## Show this help
	@echo '\\n${GENERATOR_NAME} - ${PROJECT_NAME}\\n'
	@echo 'Usage: make [target]\\n'
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  ${GREEN}%-20s${NC} %s\\n", \$\$1, \$\$2}' $(MAKEFILE_LIST)

install: ## Install dependencies
	@echo "${YELLOW}Installing dependencies...${NC}"
	pip install -r requirements.txt
	@echo "${GREEN}✓ Dependencies installed${NC}"

install-dev: ## Install development dependencies
	@echo "${YELLOW}Installing development dependencies...${NC}"
	pip install -r requirements-dev.txt
	@echo "${GREEN}✓ Development dependencies installed${NC}"

venv: ## Create virtual environment
	@echo "${YELLOW}Creating virtual environment...${NC}"
	python3 -m venv venv
	@echo "${GREEN}✓ Virtual environment created${NC}"
	@echo "${YELLOW}Activate with: source venv/bin/activate${NC}"

run: ## Run development server
	@echo "${YELLOW}Starting development server...${NC}"
	python run.py

run-prod: ## Run production server with gunicorn
	@echo "${YELLOW}Starting production server...${NC}"
	gunicorn --bind 0.0.0.0:5000 wsgi:app --workers=4 --threads=2 --timeout=120

test: ## Run tests
	@echo "${YELLOW}Running tests...${NC}"
	pytest tests/ -v --cov=app --cov-report=html

test-cov: ## Run tests with coverage report
	@echo "${YELLOW}Running tests with coverage...${NC}"
	pytest --cov=app --cov-report=html --cov-report=term-missing

lint: ## Run linters
	@echo "${YELLOW}Running linters...${NC}"
	flake8 app tests
	black --check app tests
	isort --check-only app tests

format: ## Format code
	@echo "${YELLOW}Formatting code...${NC}"
	black app tests
	isort app tests

clean: ## Clean temporary files
	@echo "${YELLOW}Cleaning temporary files...${NC}"
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -delete
	rm -rf .coverage htmlcov .pytest_cache
	@echo "${GREEN}✓ Cleaned${NC}"

db-init: ## Initialize database
	@echo "${YELLOW}Initializing database...${NC}"
	flask db init
	@echo "${GREEN}✓ Database initialized${NC}"

db-migrate: ## Create migration
	@echo "${YELLOW}Creating migration...${NC}"
	flask db migrate -m "\$(m)"
	@echo "${GREEN}✓ Migration created${NC}"

db-upgrade: ## Apply migrations
	@echo "${YELLOW}Applying migrations...${NC}"
	flask db upgrade
	@echo "${GREEN}✓ Migrations applied${NC}"

db-downgrade: ## Rollback migration
	@echo "${YELLOW}Rolling back migration...${NC}"
	flask db downgrade
	@echo "${GREEN}✓ Migration rolled back${NC}"

db-reset: ## Reset database (DANGER!)
	@echo "${RED}WARNING: This will delete all data!${NC}"
	@read -p "Are you sure? (yes/no): " confirm && [ \$\$confirm = "yes" ] || exit 1
	rm -rf migrations
	rm -f app.db
	flask db init
	flask db migrate -m "initial migration"
	flask db upgrade
	@echo "${GREEN}✓ Database reset${NC}"

docker-build: ## Build Docker image
	@echo "${YELLOW}Building Docker image...${NC}"
	docker build -t ${PROJECT_NAME} .
	@echo "${GREEN}✓ Docker image built${NC}"

docker-up: ## Start Docker containers
	@echo "${YELLOW}Starting Docker containers...${NC}"
	docker-compose up -d
	@echo "${GREEN}✓ Docker containers started${NC}"

docker-down: ## Stop Docker containers
	@echo "${YELLOW}Stopping Docker containers...${NC}"
	docker-compose down
	@echo "${GREEN}✓ Docker containers stopped${NC}"

docker-logs: ## Show Docker logs
	docker-compose logs -f

deploy-staging: ## Deploy to staging
	@echo "${YELLOW}Deploying to staging...${NC}"
	git push staging main
	@echo "${GREEN}✓ Deployed to staging${NC}"

deploy-production: ## Deploy to production
	@echo "${RED}WARNING: Deploying to production!${NC}"
	@read -p "Are you sure? (yes/no): " confirm && [ \$\$confirm = "yes" ] || exit 1
	@echo "${YELLOW}Deploying to production...${NC}"
	git push production main
	@echo "${GREEN}✓ Deployed to production${NC}"

backup: ## Create backup
	@echo "${YELLOW}Creating backup...${NC}"
	tar -czf backup_\$(date +%Y%m%d_%H%M%S).tar.gz . --exclude=venv --exclude=__pycache__ --exclude=.git
	@echo "${GREEN}✓ Backup created${NC}"

shell: ## Open Flask shell
	flask shell

celery-worker: ## Start Celery worker
	celery -A app.tasks.celery worker --loglevel=info

celery-beat: ## Start Celery beat
	celery -A app.tasks.celery beat --loglevel=info

generate-secret: ## Generate secret key
	@python -c "import secrets; print(secrets.token_hex(32))"

info: ## Show project information
	@echo "\\n${GREEN}${PROJECT_NAME}${NC}"
	@echo "Generated with ${GENERATOR_NAME} by ${AUTHOR_NAME}"
	@echo "GitHub: ${AUTHOR_GITHUB}\\n"
	@echo "Commands:"
	@echo "  make run       - Start development server"
	@echo "  make test      - Run tests"
	@echo "  make docker-up - Start with Docker"
	@echo "  make help      - Show all commands\\n"
EOF
    fi
    
    # README.md completo
    cat > README.md << EOF
# ${PROJECT_NAME}

![Flask](https://img.shields.io/badge/Flask-2.3%2B-blue)
![Python](https://img.shields.io/badge/Python-3.9%2B-green)
![License](https://img.shields.io/badge/License-MIT-yellow)
![Generator](https://img.shields.io/badge/Generated_with-FlaskProyect_Maker-purple)

> Una aplicación Flask profesional generada automáticamente con **${GENERATOR_NAME}** por **${AUTHOR_NAME}**

## 🚀 Características

### Backend
$( [ ${LIBRARIES["flask_sqlalchemy"]} -eq 1 ] && echo "- ✅ Base de datos con SQLAlchemy" )
$( [ ${LIBRARIES["flask_login"]} -eq 1 ] && echo "- ✅ Autenticación con Flask-Login" )
$( [ ${LIBRARIES["flask_wtf"]} -eq 1 ] && echo "- ✅ Formularios con Flask-WTF" )
$( [ ${LIBRARIES["flask_migrate"]} -eq 1 ] && echo "- ✅ Migraciones con Flask-Migrate" )
$( [ ${LIBRARIES["flask_restx"]} -eq 1 ] && echo "- ✅ API REST con Flask-RESTx" )
$( [ ${LIBRARIES["flask_mail"]} -eq 1 ] && echo "- ✅ Sistema de emails" )
$( [ ${LIBRARIES["flask_admin"]} -eq 1 ] && echo "- ✅ Panel de administración" )
$( [ ${LIBRARIES["flask_socketio"]} -eq 1 ] && echo "- ✅ WebSocket con Socket.IO" )

### Frontend
$( [ ${LIBRARIES["bootstrap"]} -eq 1 ] && echo "- ✅ Bootstrap 5 responsive" )
$( [ ${LIBRARIES["tailwind"]} -eq 1 ] && echo "- ✅ Tailwind CSS" )
$( [ ${LIBRARIES["jquery"]} -eq 1 ] && echo "- ✅ jQuery" )
$( [ ${LIBRARIES["alpinejs"]} -eq 1 ] && echo "- ✅ Alpine.js" )
$( [ ${LIBRARIES["fontawesome"]} -eq 1 ] && echo "- ✅ Font Awesome icons" )

### DevOps
$( [ $USE_DOCKER -eq 1 ] && echo "- ✅ Docker containerization" )
$( [ $USE_DOCKER_COMPOSE -eq 1 ] && echo "- ✅ Docker Compose multi-service" )
$( [ $USE_NGINX -eq 1 ] && echo "- ✅ Nginx reverse proxy" )
$( [ ${LIBRARIES["gunicorn"]} -eq 1 ] && echo "- ✅ Gunicorn production server" )
$( [ $USE_GITHUB_ACTIONS -eq 1 ] && echo "- ✅ GitHub Actions CI/CD" )

### Testing
$( [ ${LIBRARIES["pytest"]} -eq 1 ] && echo "- ✅ Pytest test suite" )
$( [ ${LIBRARIES["coverage"]} -eq 1 ] && echo "- ✅ Coverage reporting" )
$( [ ${LIBRARIES["faker"]} -eq 1 ] && echo "- ✅ Faker for test data" )

## 📁 Estructura del Proyecto

\`\`\`
${PROJECT_NAME}/
├── app/                          # Código de la aplicación
│   ├── __init__.py              # Factory de la aplicación
│   ├── models/                  # Modelos de datos
│   ├── routes/                  # Blueprints y rutas
│   ├── templates/               # Plantillas Jinja2
│   ├── static/                  # Archivos estáticos
│   ├── forms/                   # Formularios WTForms
│   ├── utils/                   # Utilidades
│   └── config/                  # Configuración
├── tests/                       # Tests automatizados
├── migrations/                  # Migraciones de base de datos
├── docker/                      # Configuración Docker
├── docs/                        # Documentación
├── requirements.txt             # Dependencias
├── Dockerfile                   # Docker image
├── docker-compose.yml          # Docker Compose
├── Makefile                    # Comandos útiles
└── README.md                   # Esta documentación
\`\`\`

## 🛠️ Instalación Rápida

### 1. Clonar y configurar
\`\`\`bash
# Crear entorno virtual (recomendado)
python -m venv venv

# Activar entorno
source venv/bin/activate  # Linux/Mac
# venv\\Scripts\\activate  # Windows

# Instalar dependencias
pip install -r requirements.txt
\`\`\`

### 2. Configurar variables de entorno
\`\`\`bash
cp .env.example .env
# Editar .env con tus valores
\`\`\`

### 3. Inicializar base de datos
\`\`\`bash
flask db init
flask db migrate -m "Initial migration"
flask db upgrade
\`\`\`

### 4. Ejecutar la aplicación
\`\`\`bash
# Desarrollo
python run.py

# Producción (con Gunicorn)
gunicorn --bind 0.0.0:5000 wsgi:app
\`\`\`

### 5. Visitar la aplicación
Abre tu navegador en: [http://localhost:5000](http://localhost:5000)

## 🐳 Docker

### Desarrollo
\`\`\`bash
docker-compose up -d
\`\`\`

### Producción
\`\`\`bash
docker build -t ${PROJECT_NAME} .
docker run -p 5000:5000 --env-file .env ${PROJECT_NAME}
\`\`\`

## 🧪 Testing

\`\`\`bash
# Ejecutar todos los tests
pytest tests/

# Ejecutar tests con cobertura
pytest --cov=app --cov-report=html

# Ejecutar tests específicos
pytest tests/test_auth.py -v
\`\`\`

## 🔧 Comandos Útiles (Makefile)

\`\`\`bash
make help         # Mostrar ayuda
make run          # Iniciar servidor de desarrollo
make test         # Ejecutar tests
make lint         # Ejecutar linters
make format       # Formatear código
make docker-up    # Iniciar con Docker
make db-migrate   # Crear migración
\`\`\`

## 📡 API

La aplicación incluye una API REST completa con documentación Swagger:

- **Documentación:** \`GET /api/docs\`
- **Health check:** \`GET /api/health\`
- **Endpoints:** \`GET /api/v1/\`

## 🔐 Seguridad

- Autenticación con JWT tokens
- Protección CSRF
- Rate limiting configurable
- Hashing de contraseñas con bcrypt
- Headers de seguridad HTTP

## 📊 Monitoreo

- Logging estructurado
- Métricas de rendimiento
- Health checks automatizados
- Integración con Sentry (opcional)

## 🤝 Contribución

1. Fork el proyecto
2. Crear rama de feature (\`git checkout -b feature/AmazingFeature\`)
3. Commit cambios (\`git commit -m 'Add AmazingFeature'\`)
4. Push a la rama (\`git push origin feature/AmazingFeature\`)
5. Abrir Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver \`LICENSE\` para más detalles.

## 🎯 Generador

Este proyecto fue generado automáticamente usando:

**${GENERATOR_NAME}**  
Creado por: **${AUTHOR_NAME}**  
GitHub: [${AUTHOR_GITHUB}](${AUTHOR_GITHUB})

## 🆘 Soporte

- Documentación: \`docs/\` directory
- Issues: Reportar bugs en GitHub
- Preguntas: Abrir discussion en GitHub

---

**¡Gracias por usar ${GENERATOR_NAME}!** 🚀

Desarrollado con ❤️ por [${AUTHOR_NAME}](${AUTHOR_GITHUB})
EOF

    print_success "Archivos adicionales creados"
}

setup_environment() {
    print_step "Configurando entorno..."
    
    # Crear entorno virtual si se seleccionó
    if [ $USE_VENV -eq 1 ]; then
        if command -v python3 &> /dev/null; then
            python3 -m venv venv
            if [ $? -eq 0 ]; then
                print_success "Entorno virtual creado"
                
                # Instalar Flask básico
                source venv/bin/activate 2>/dev/null
                pip install --upgrade pip > /dev/null 2>&1
                pip install flask python-dotenv > /dev/null 2>&1
                deactivate 2>/dev/null
            else
                print_warning "No se pudo crear entorno virtual"
            fi
        else
            print_warning "Python3 no encontrado, saltando entorno virtual"
        fi
    fi
    
    # Inicializar Git si se seleccionó
    if [ $USE_GIT -eq 1 ]; then
        if command -v git &> /dev/null; then
            git init > /dev/null 2>&1
            git add . > /dev/null 2>&1
            git commit -m "Initial commit: ${PROJECT_NAME} created with ${GENERATOR_NAME}" > /dev/null 2>&1
            print_success "Repositorio Git inicializado"
        else
            print_warning "Git no encontrado, saltando inicialización"
        fi
    fi
    
    # Crear archivo .env desde ejemplo
    if [ -f ".env.example" ]; then
        cp .env.example .env 2>/dev/null
        print_success "Archivo .env creado (edita con tus valores)"
    fi
}

show_final_instructions() {
    print_header
    
    echo -e "${GREEN}🎉 ¡PROYECTO CREADO EXITOSAMENTE!${NC}\n"
    
    echo -e "${CYAN}📁 Proyecto:${NC} ${PROJECT_NAME}"
    echo -e "${CYAN}📂 Ubicación:${NC} ${PROJECT_PATH}\n"
    
    echo -e "${YELLOW}🚀 PARA COMENZAR:${NC}\n"
    
    if [ $USE_VENV -eq 1 ] && [ -d "venv" ]; then
        echo -e "  1. Activar entorno virtual:"
        echo -e "     ${GREEN}cd ${PROJECT_NAME} && source venv/bin/activate${NC}\n"
    else
        echo -e "  1. Navegar al proyecto:"
        echo -e "     ${GREEN}cd ${PROJECT_NAME}${NC}\n"
    fi
    
    echo -e "  2. Instalar dependencias:"
    echo -e "     ${GREEN}pip install -r requirements.txt${NC}\n"
    
    echo -e "  3. Configurar variables de entorno:"
    echo -e "     ${GREEN}cp .env.example .env${NC}"
    echo -e "     ${YELLOW}# Edita .env con tus valores${NC}\n"
    
    echo -e "  4. Inicializar base de datos:"
    echo -e "     ${GREEN}flask db upgrade${NC}\n"
    
    echo -e "  5. Ejecutar la aplicación:"
    echo -e "     ${GREEN}python run.py${NC}\n"
    
    echo -e "  6. Abrir en navegador:"
    echo -e "     ${GREEN}http://localhost:5000${NC}\n"
    
    echo -e "${PURPLE}🛠️  COMANDOS ÚTILES:${NC}\n"
    
    if [ $USE_MAKEFILE -eq 1 ]; then
        echo -e "  ${GREEN}make run${NC}      - Iniciar servidor"
        echo -e "  ${GREEN}make test${NC}     - Ejecutar tests"
        echo -e "  ${GREEN}make docker-up${NC} - Iniciar con Docker"
        echo -e "  ${GREEN}make help${NC}     - Ver todos los comandos\n"
    fi
    
    echo -e "${CYAN}📚 DOCUMENTACIÓN:${NC}\n"
    echo -e "  - README.md: Instrucciones completas"
    echo -e "  - /api/docs: Documentación API interactiva"
    echo -e "  - Carpeta docs/: Documentación detallada\n"
    
    echo -e "${GREEN}🌟 CARACTERÍSTICAS INCLUIDAS:${NC}\n"
    
    [ $USE_AUTH_SYSTEM -eq 1 ] && echo -e "  ✅ Sistema de autenticación"
    [ $USE_API -eq 1 ] && echo -e "  ✅ API REST con documentación"
    [ $USE_EMAIL -eq 1 ] && echo -e "  ✅ Sistema de emails"
    [ $USE_DOCKER -eq 1 ] && echo -e "  ✅ Configuración Docker"
    [ ${LIBRARIES["bootstrap"]} -eq 1 ] && echo -e "  ✅ Bootstrap 5 responsive"
    [ ${LIBRARIES["flask_admin"]} -eq 1 ] && echo -e "  ✅ Panel de administración"
    
    echo -e "\n${YELLOW}🎯 GENERADO CON:${NC}\n"
    echo -e "  ${GENERATOR_NAME}"
    echo -e "  Por: ${AUTHOR_NAME}"
    echo -e "  GitHub: ${AUTHOR_GITHUB}\n"
    
    echo -e "${RED}⚠️  IMPORTANTE:${NC}"
    echo -e "  1. Cambia las claves secretas en .env"
    echo -e "  2. Revisa la configuración de base de datos"
    echo -e "  3. Configura el sistema de emails si es necesario\n"
    
    echo -e "${GREEN}¡FELIZ DESARROLLO! 🚀${NC}\n"
    
    # Mostrar estructura del proyecto
    echo -e "${CYAN}📁 Estructura creada:${NC}"
    find . -type f -name "*.py" | head -20 | sed 's|^\./||' | while read file; do
        echo "  📄 $file"
    done
    
    echo -e "\n${YELLOW}⏰ Tiempo estimado para empezar: 5 minutos${NC}"
}

# Función principal
main() {
    print_header
    
    # Verificar dependencias
    if ! command -v python3 &> /dev/null; then
        print_error "Python3 no está instalado"
        echo "Instala Python3 antes de continuar:"
        echo "  Ubuntu/Debian: sudo apt install python3 python3-venv"
        echo "  macOS: brew install python"
        echo "  Windows: https://python.org/downloads/"
        exit 1
    fi
    
    # Obtener información del proyecto
    get_project_info
}

# Punto de entrada
main "$@"