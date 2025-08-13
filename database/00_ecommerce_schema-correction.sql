-- Active: 1753172326626@@127.0.0.1@5432@ecommerce_fr_db
-- =====================================================
-- E-COMMERCE DATABASE - PostgreSQL 17 - VERSION COMPLÈTE
-- Version KISS : Simple, Fonctionnelle, Évolutive avec RLS et VUES
-- PRINCIPE : Séparation claire des responsabilités
-- - USERS : Authentification pure (customers + admins)
-- - USER_PROFILES : Données personnelles étendues
-- - ADMIN crée et gère les PRODUCTS
-- - CUSTOMERS naviguent et achètent
-- =====================================================

-- CREATE DATABASE ecommerce_fr_db
-- WITH ENCODING 'UTF8'
-- LC_COLLATE = 'fr_FR.UTF-8'
-- LC_CTYPE = 'fr_FR.UTF-8'
-- TEMPLATE template0;


-- \c ecommerce_fr_db; commande à réaliser en ligne de commande pour accéder à la base de données

-- =====================================================
-- EXTENSIONS ESSENTIELLES
-- =====================================================
-- Insensibilité à la casse
CREATE EXTENSION IF NOT EXISTS citext;

-- Recherche de texte intégrale (Full Text Search)
CREATE EXTENSION IF NOT EXISTS pg_trgm;
-- Recherche floue/similitude

-- UUID si besoin pour les identifiants
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- CRÉATION DES RÔLES DE SÉCURITÉ (RÔLES DATABASE)
-- =====================================================
-- JUSTIFICATION : Séparation des permissions pour RLS, Pattern utilisé par 90%+ des entreprises tech
-- USAGE : Rôles PostgreSQL (connexion DB)
-- EXEMPLES : Supabase, PostgREST, Hasura, Stripe, Shopify

-- D'abord supprimer tous les objets possédés par les rôles
-- DROP OWNED BY admin_bookstore;
-- DROP OWNED BY customer_bookstore;
-- DROP OWNED BY api_service_bookstore;

-- -- ENSUITE supprimer les rôles
-- DROP ROLE IF EXISTS admin_bookstore;
-- DROP ROLE IF EXISTS customer_bookstore;
-- DROP ROLE IF EXISTS api_service_bookstore;
CREATE ROLE api_service_bookstore WITH LOGIN PASSWORD 'secure_password';
-- Service backend Node.js
CREATE ROLE customer_bookstore WITH NOLOGIN;
-- Rôle hérité par les clients
CREATE ROLE admin_bookstore WITH NOLOGIN;
-- Rôle hérité par les admins

-- =====================================================
-- THÈME : AUTHENTIFICATION & PROFILS
-- =====================================================
-- JUSTIFICATION : Base sécurisée pour tous les utilisateurs
-- ENDPOINTS LIÉS :
-- - POST /api/v1/auth/login
-- - GET /api/v1/profile
-- - PUT /api/v1/profile
-- TABLES : users, user_profiles

-- TABLE : users

-- RÔLE MÉTIER : Authentification pure et gestion des rôles
-- RELATIONS :
-- └─ users 1:1 user_profiles (profil étendu)
-- └─ users 1:N products (admin créateur)
-- └─ users 1:N orders (customer acheteur)


/* TODO: Création de la table user_roles */
-- -----------------------------------------------------
-- TABLE : user_roles
-- -----------------------------------------------------
-- RÔLE MÉTIER : Référentiel simple des rôles utilisateurs (customer, admin)
-- RELATIONS :
--   └─ user_roles 1:N users (un rôle peut être assigné à plusieurs utilisateurs)
-- PRINCIPE : KISS - Fonctionnalités de base uniquement, évolutif si besoin

CREATE TABLE IF NOT EXISTS user_roles (
    id SERIAL PRIMARY KEY,                           -- PK auto-incrémentée pour référence
    -- === IDENTIFICATION DU RÔLE ===
    role_name VARCHAR(20) UNIQUE NOT NULL,           -- Nom technique utilisé dans l'API (customer, admin)
    description VARCHAR(255),                        -- Description lisible pour les interfaces utilisateur
    -- === AUDIT MINIMAL ===
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Date création automatique
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Date dernière modification (géré par API)
    -- === CONTRAINTES CRITIQUES UNIQUEMENT ===
    CONSTRAINT check_role_name_format CHECK (
        role_name ~ '^[a-z_]+$'                     -- Format standardisé : lettres minuscules + underscores uniquement
    ),
    CONSTRAINT check_role_name_length CHECK (
        char_length(role_name) BETWEEN 3 AND 20     -- Longueur raisonnable pour éviter erreurs
    )
);

-- =====================================================
-- INDEX OPTIMISÉ POUR PERFORMANCES API
-- =====================================================

-- JUSTIFICATION : Recherche fréquente par nom de rôle lors de l'authentification
-- USAGE : SELECT * FROM user_roles WHERE role_name = 'customer' (login process)
CREATE INDEX IF NOT EXISTS idx_user_roles_name
ON user_roles (role_name);

-- =====================================================
-- RLS : ROW LEVEL SECURITY
-- =====================================================

ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

-- JUSTIFICATION : Tous les utilisateurs connectés peuvent lire les rôles
-- USAGE : Interface utilisateur peut afficher les rôles disponibles
CREATE POLICY user_roles_read_all ON user_roles
FOR SELECT
USING (true);                                        -- Lecture libre pour tous les rôles connectés

-- JUSTIFICATION : Seuls les admins peuvent modifier les rôles
-- USAGE : Panel admin pour créer/modifier des rôles personnalisés
CREATE POLICY user_roles_admin_write ON user_roles
FOR ALL TO admin_bookstore
USING (true);

-- JUSTIFICATION : API service a accès complet pour gestion backend
-- USAGE : Node.js API peut gérer les rôles sans restriction
CREATE POLICY user_roles_api_service ON user_roles
FOR ALL TO api_service_bookstore
USING (true);

-- =====================================================
-- !ATTENTION : DISTINCTION IMPORTANTE
-- =====================================================
-- • customer_bookstore = Rôle PostgreSQL (connexion DB)
-- • 'customer' = Rôle métier application (données)
-- Ces deux concepts sont DIFFÉRENTS et ne se mélangent pas

-- =====================================================
-- DONNÉES DE RÉFÉRENCE - RÔLES DE BASE DE L'APPLICATION
-- =====================================================

-- JUSTIFICATION : Rôles minimum pour démarrer l'application
-- customer : Utilisateurs standard qui achètent
-- admin : Gestionnaires avec accès complet
INSERT INTO user_roles (role_name, description) VALUES
('customer', 'Client standard - achat et consultation'),
('admin', 'Administrateur - gestion complète du système')
ON CONFLICT (role_name) DO NOTHING;                  -- Évite erreur si rôles déjà présents

-- =====================================================
-- COMMENTAIRES TECHNIQUES POUR LA MAINTENANCE
-- =====================================================

COMMENT ON TABLE user_roles IS
'Table de référence des rôles utilisateurs. Version KISS : fonctionnalités essentielles uniquement.';

COMMENT ON COLUMN user_roles.role_name IS
'Nom technique du rôle utilisé dans le code API (customer, admin, moderator...). Format : minuscules + underscores.';

COMMENT ON COLUMN user_roles.description IS
'Description lisible du rôle pour les interfaces utilisateur et la documentation.';

COMMENT ON COLUMN user_roles.created_at IS
'Date de création automatique. Utile pour audit et historique des rôles.';

COMMENT ON COLUMN user_roles.updated_at IS
'Date de dernière modification. Doit être mise à jour manuellement par l''API lors des modifications.';

-- =====================================================
-- NOTES POUR LES DÉVELOPPEURS
-- =====================================================

/*
ÉVOLUTION POSSIBLE :
- Ajouter is_active si on veut désactiver des rôles sans les supprimer
- Ajouter permissions granulaires si le système devient complexe
- Créer une table user_role_permissions pour des droits avancés

USAGE API TYPIQUE :
1. Login : SELECT role_name FROM user_roles ur JOIN users u ON u.role_id = ur.id WHERE u.email = ?
2. Interface admin : SELECT * FROM user_roles ORDER BY role_name
3. Création utilisateur : SELECT id FROM user_roles WHERE role_name = 'customer'

SÉCURITÉ :
- RLS activé : protection automatique selon les rôles
- Contraintes de format : évite les erreurs de saisie
- UNIQUE sur role_name : pas de doublons
*/


CREATE TABLE IF NOT EXISTS users (
id SERIAL PRIMARY KEY,
-- === AUTHENTIFICATION ===
username CITEXT UNIQUE NOT NULL, -- Identifiant unique pour login
email CITEXT UNIQUE NOT NULL, -- Email pour login + notifications
password_hash VARCHAR(255) NOT NULL, -- Hash argon2 du mot de passe
role_id INTEGER NOT NULL DEFAULT 1, -- ID du rôle 'customer'
-- === STATUT COMPTE ===
is_active BOOLEAN DEFAULT TRUE, -- Compte activé/désactivé
is_connected BOOLEAN DEFAULT FALSE, -- Compte connecté/déconnecté
email_verified BOOLEAN DEFAULT FALSE, -- Email confirmé
-- === RGPD OBLIGATOIRE ===
gdpr_consent BOOLEAN NOT NULL DEFAULT FALSE, -- Consentement RGPD requis
gdpr_consent_date TIMESTAMP, -- Date du consentement
-- === AUDIT ===
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
last_login_at TIMESTAMP, -- Dernière connexion (gérer par le server Nodejs)
-- === CONTRAINTES MÉTIER ===
CONSTRAINT username_length CHECK (
    char_length(username) BETWEEN 3 AND 30
),
CONSTRAINT email_length CHECK (char_length(email) <= 255),
CONSTRAINT valid_email CHECK (email ~* '^[^\s@]+@[^\s@]+\.[^\s@]+$'),
-- === CONTRAINTES DE RÉFÉRENCE ===
CONSTRAINT fk_users_role FOREIGN KEY (role_id) REFERENCES user_roles(id)
);

-- =====================================================
-- INDEX OPTIMISÉS POUR AUTHENTIFICATION
-- =====================================================

-- JUSTIFICATION : Login rapide email/username sur comptes actifs uniquement
CREATE INDEX IF NOT EXISTS idx_users_email
ON users (email)
WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_users_username
ON users (username)
WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_users_role_id
ON users (role_id);
-- Admin : gestion par rôle

-- =====================================================
-- RLS : ROW LEVEL SECURITY
-- =====================================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Customers : accès uniquement à leurs propres données
CREATE POLICY users_customer_access ON users
    FOR ALL TO customer_bookstore
    USING (true);  -- Node.js fait WHERE id = $1

-- Admins : accès complet
CREATE POLICY admin_full_users ON users
    FOR ALL TO admin_bookstore
    USING (true);

-- API Service : accès complet pour backend Node.js
CREATE POLICY api_service_full_access ON users
    FOR ALL TO api_service_bookstore
    USING (true);


-- TABLE : user_sessions
-- RÔLE MÉTIER : Gestion refresh tokens multi-appareils pour sessions stateful (7 jours)
-- RELATIONS :
-- └─ users 1:N user_sessions (CASCADE DELETE) = un utilisateur peut avoir plusieurs tokens par device

CREATE TABLE IF NOT EXISTS user_sessions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
-- === SESSION DATA ===
refresh_token VARCHAR(255) NOT NULL UNIQUE, -- Token de rafraîchissement (7 jours)
device_type VARCHAR(20) NOT NULL, -- web/mobile/tablet/desktop
-- === GESTION EXPIRATION ===
expires_at TIMESTAMP NOT NULL, -- Expiration refresh token (7 jours)
-- === STATUT ===
is_active BOOLEAN DEFAULT TRUE, -- Token actif/révoqué
-- === AUDIT MINIMAL ===
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
-- === CONTRAINTES DE RÉFÉRENCE ===
CONSTRAINT fk_user_sessions_user_id FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
-- === CONTRAINTES MÉTIER ===
CONSTRAINT valid_expiration CHECK (expires_at > created_at),
CONSTRAINT valid_device_type CHECK (
    device_type IN (
        'web',
        'mobile',
        'tablet',
        'desktop'
    )
),
-- UN SEUL TOKEN ACTIF PAR DEVICE
CONSTRAINT unique_active_token_per_device
        EXCLUDE (user_id WITH =, device_type WITH =)
        WHERE (is_active = TRUE)
);

-- INDEX JUSTIFICATIONS :
-- - Recherche refresh token (authentification stateful)
CREATE INDEX IF NOT EXISTS idx_user_sessions_token ON user_sessions (refresh_token);

-- - Nettoyage tokens expirés (tâche cron)
CREATE INDEX IF NOT EXISTS idx_user_sessions_expires ON user_sessions (expires_at);

-- - Sessions par utilisateur + device (gestion multi-device)
CREATE INDEX IF NOT EXISTS idx_user_sessions_user_device ON user_sessions (user_id, device_type);

-- RLS JUSTIFICATION : Tokens privés par utilisateur
ALTER TABLE user_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY sessions_customer_access ON user_sessions
    FOR ALL TO customer_bookstore
    USING (true);  -- Node.js filtre avec WHERE user_id = $1

CREATE POLICY sessions_admin_all ON user_sessions
    FOR ALL TO admin_bookstore
    USING (true);  -- Admin accès complet

CREATE POLICY sessions_api_service_full ON user_sessions
    FOR ALL TO api_service_bookstore
    USING (true);

-- TABLE : user_profiles

-- RÔLE MÉTIER : Données personnelles étendues séparées de l'auth
-- RELATIONS :
-- └─ users 1:1 user_profiles (CASCADE DELETE) = si l'utilisateur est supprimé, son profil est supprimé

CREATE TABLE IF NOT EXISTS user_profiles (
id SERIAL PRIMARY KEY,
user_id INTEGER NOT NULL UNIQUE, -- Lien vers utilisateur, unique permet l'index sur user_id automatiquement
-- === INFORMATIONS PERSONNELLES ===
first_name VARCHAR(100), -- Prénom (utilisé pour adresses)
last_name VARCHAR(100), -- Nom (utilisé pour adresses)
phone VARCHAR(20), -- Téléphone pour livraisons
birth_date DATE, -- Date naissance (optionnel)
-- === PRÉFÉRENCES MARKETING ===
newsletter_consent BOOLEAN DEFAULT FALSE, -- Consentement newsletter séparé
newsletter_consent_date TIMESTAMP, -- Date consentement newsletter
-- === AVATAR (OPTIONNEL) ===
avatar_url VARCHAR(500), -- URL image profil uploadée
-- === AUDIT ===
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
-- === CONTRAINTES DE RÉFÉRENCE ===
CONSTRAINT fk_user_profiles_user_id
FOREIGN KEY (user_id)
REFERENCES users (id) ON DELETE CASCADE, -- si l'utilisateur est supprimé, son profil est supprimés
-- === CONTRAINTES MÉTIER ===
CONSTRAINT valid_phone CHECK (phone IS NULL OR phone ~* '^\+?[0-9\s\-\.]{10,15}$')
);
-- RLS JUSTIFICATION : Profils privés par utilisateur
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY profiles_customer_access ON user_profiles
    FOR ALL TO customer_bookstore
    USING (true);  -- Node.js fait WHERE user_id = $1

CREATE POLICY admin_full_profiles ON user_profiles
    FOR ALL TO admin_bookstore
    USING (true);
CREATE POLICY api_service_full_profiles ON user_profiles
    FOR ALL TO api_service_bookstore
    USING (true);


-- =====================================================
-- THÈME : USER MANAGEMENT
-- =====================================================
-- JUSTIFICATION : Données sensibles utilisateur (cartes bancaires)
-- ENDPOINTS LIÉS :
--   POST /api/payment-methods (ajouter carte)
--   GET /api/payment-methods (lister cartes user)
--   PUT /api/payment-methods/:id (modifier carte)
--   DELETE /api/payment-methods/:id (supprimer carte)

-- -----------------------------------------------------
-- TABLE : user_payment_methods
-- -----------------------------------------------------
-- RÔLE MÉTIER : Stockage sécurisé des moyens de paiement utilisateur
-- RELATIONS :
-- └─ users 1:N user_payment_methods (CASCADE DELETE) = un utilisateur peut avoir plusieurs cartes

CREATE TABLE IF NOT EXISTS user_payment_methods (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
-- === DONNÉES CARTE (CHIFFRÉES CÔTÉ API) ===
card_token VARCHAR(255) NOT NULL, -- Token Stripe/externe (pas les vrais numéros)
card_last4 VARCHAR(4) NOT NULL, -- 4 derniers chiffres (affichage UX)
card_brand VARCHAR(20) NOT NULL, -- visa/mastercard/amex
card_type VARCHAR(10) DEFAULT 'card', -- card/paypal/apple_pay
-- === MÉTADONNÉES CARTE ===
cardholder_name VARCHAR(100), -- Nom sur la carte
expires_month SMALLINT, -- Mois expiration (1-12)
expires_year SMALLINT, -- Année expiration
-- === GESTION UTILISATEUR ===
nickname VARCHAR(50), -- "Ma carte perso", "Carte travail"
is_default BOOLEAN DEFAULT FALSE, -- Carte par défaut
is_active BOOLEAN DEFAULT TRUE, -- Carte active/désactivée
-- === AUDIT MINIMAL ===
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
-- === CONTRAINTES DE RÉFÉRENCE ===
CONSTRAINT fk_payment_methods_user_id FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
-- === CONTRAINTES MÉTIER ===
CONSTRAINT valid_expiration_month CHECK (
    expires_month >= 1
    AND expires_month <= 12
),
CONSTRAINT valid_expiration_year CHECK (
    expires_year >= EXTRACT(
        YEAR
        FROM CURRENT_DATE
    )
),
CONSTRAINT valid_card_brand CHECK (
    card_brand IN (
        'visa',
        'mastercard',
        'amex',
        'discover',
        'unknown'
    )
),
CONSTRAINT valid_card_type CHECK (
    card_type IN (
        'card',
        'paypal',
        'apple_pay',
        'google_pay'
    )
),
CONSTRAINT valid_last4 CHECK (
    card_last4 ~ '^[0-9]{4}$' -- Exactement 4 chiffres
),
-- UN SEUL MOYEN DE PAIEMENT PAR DÉFAUT
CONSTRAINT unique_default_payment_per_user
        EXCLUDE (user_id WITH =)
        WHERE (is_default = TRUE AND is_active = TRUE)
);

-- INDEX JUSTIFICATIONS :
-- - Recherche cartes par utilisateur (endpoint principal)
CREATE INDEX IF NOT EXISTS idx_payment_methods_user ON user_payment_methods (user_id, is_active);

-- - Recherche carte par défaut (checkout rapide)
CREATE INDEX IF NOT EXISTS idx_payment_methods_default ON user_payment_methods (user_id, is_default)
WHERE is_default = TRUE AND is_active = TRUE;

-- - Token unique (sécurité + intégrité Stripe)
CREATE UNIQUE INDEX idx_payment_methods_token ON user_payment_methods (card_token);

-- RLS DOUBLE SÉCURITÉ : Cartes ultra-sensibles
ALTER TABLE user_payment_methods ENABLE ROW LEVEL SECURITY;

-- Policy utilisateur : voit seulement ses cartes
CREATE POLICY payment_methods_customer_access ON user_payment_methods
    FOR ALL TO customer_bookstore
    USING (true);  -- Node.js fait WHERE user_id = $1

-- Policy admin : accès complet pour support client
CREATE POLICY admin_full_payment_methods ON user_payment_methods
    FOR ALL TO admin_bookstore
    USING (true);

-- Policy service API : accès technique complet
CREATE POLICY api_service_full_payment_methods ON user_payment_methods
    FOR ALL TO api_service_bookstore
    USING (true);

-- =====================================================
-- THÈME : RÉFÉRENTIELS MÉTIER
-- =====================================================
-- JUSTIFICATION : Tables de référence pour la conformité fiscale et organisation
-- ENDPOINTS LIÉS :
-- - GET /api/v1/categories (navigation)
-- - GET /api/v1/tax-rates (calculs checkout)
-- - POST /api/v1/admin/tax-rates (gestion admin)
-- TABLES : tax_rates, categories

-- -----------------------------------------------------
-- TABLE : tax_rates
-- -----------------------------------------------------
-- RÔLE MÉTIER : Centraliser les taux TVA pour conformité fiscale française
-- RELATIONS :
-- └─ tax_rates 1:N products (calcul TVA par produit)

CREATE TABLE IF NOT EXISTS tax_rates (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,           -- Ex: "TVA Normale 20%"
    rate DECIMAL(5,4) NOT NULL,                 -- Ex: 0.2000 pour 20%
    description TEXT,                           -- Explication légale du taux
    is_active BOOLEAN DEFAULT TRUE,             -- Désactiver anciens taux
-- === AUDIT ===
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
-- === CONTRAINTES MÉTIER ===
CONSTRAINT valid_tax_rate CHECK (rate >= 0 AND rate <= 1),         -- Entre 0% et 100%
    CONSTRAINT unique_active_rate EXCLUDE (rate WITH =) WHERE (is_active = true)  -- Pas de doublons actifs
);

-- JUSTIFICATION INDEX : Recherche des taux actifs (endpoint checkout fréquent)
CREATE INDEX IF NOT EXISTS idx_tax_rates_active ON tax_rates (is_active)
WHERE is_active = true;

-- JUSTIFICATION INDEX : Recherche par nom (interface admin)
CREATE INDEX IF NOT EXISTS idx_tax_rates_name ON tax_rates (name)
WHERE is_active = true;

-- RLS JUSTIFICATION : Lecture publique, modification admin uniquement
ALTER TABLE tax_rates ENABLE ROW LEVEL SECURITY;

CREATE POLICY tax_rates_read_all ON tax_rates FOR
SELECT USING (is_active = true);

CREATE POLICY admin_manage_tax_rates ON tax_rates FOR ALL TO admin_bookstore USING (true);

-- DONNÉES RÉFÉRENCE FRANCE 2025
INSERT INTO
    tax_rates (name, rate, description)
VALUES (
        'TVA Standard',
        0.2000,
        'Taux normal 20% - biens et services courants'
    ),
    (
        'TVA Réduite',
        0.1000,
        'Taux réduit 10% - restauration, transports'
    ),
    (
        'TVA Super Réduite',
        0.0550,
        'Taux super réduit 5,5% - alimentation, livres'
    ),
    (
        'Franchise TVA',
        0.0000,
        'Exonération de TVA - micro-entreprises'
    );

-- -----------------------------------------------------
-- TABLE : categories pattern "Adjacency List"
-- -----------------------------------------------------
-- RÔLE MÉTIER : Organisation hiérarchique du catalogue produits
-- RELATIONS :
-- └─ categories 1:N categories (hiérarchie parent/enfant)
-- └─ categories 1:N products (classification)

CREATE TABLE IF NOT EXISTS categories (
    id SERIAL PRIMARY KEY,
    name CITEXT NOT NULL,                           -- CITEXT pour recherche insensible casse
    slug CITEXT UNIQUE NOT NULL,                    -- CITEXT évite doublons URL
    description TEXT,                               -- Description SEO
    parent_id INTEGER,                              -- Catégorie parente (NULL = racine)
-- === HIÉRARCHIE ===
level INTEGER DEFAULT 0, -- Niveau hiérarchique (0=racine)
sort_order INTEGER DEFAULT 0, -- Ordre d'affichage
-- === SEO ===
meta_title VARCHAR(200), -- Titre page catégorie
meta_description VARCHAR(300), -- Meta description SEO
-- === STATUT ===
is_active BOOLEAN DEFAULT TRUE, -- Catégorie visible
-- === AUDIT ===
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
-- === CONTRAINTES RÉFÉRENCE ===
CONSTRAINT fk_categories_parent FOREIGN KEY (parent_id) REFERENCES categories (id),
-- === CONTRAINTES MÉTIER ===
CONSTRAINT no_self_parent CHECK (parent_id != id),                    -- Éviter boucle
CONSTRAINT valid_slug CHECK (slug ~ '^[a-z0-9\-]+$'),                 -- Format URL strict
CONSTRAINT valid_level CHECK (level >= 0 AND level <= 5),             -- Limite profondeur
CONSTRAINT name_length CHECK (char_length(name) <= 100),              -- LIMITE CITEXT NAME
CONSTRAINT slug_length CHECK (char_length(slug) <= 100),              -- LIMITE CITEXT SLUG
    CONSTRAINT slug_not_empty CHECK (char_length(slug) >= 2)          -- Slug minimum 2 chars
);

-- INDEX JUSTIFICATION : Navigation catalogue hiérarchique
CREATE INDEX IF NOT EXISTS idx_categories_parent ON categories (parent_id)
WHERE
    is_active = true;
-- INDEX JUSTIFICATION : Recherche catégories actives (endpoint fréquent)
CREATE INDEX IF NOT EXISTS idx_categories_active ON categories (is_active, sort_order);
-- INDEX JUSTIFICATION : Pages catégories SEO
CREATE INDEX IF NOT EXISTS idx_categories_slug ON categories (slug)
WHERE
    is_active = true;
-- INDEX JUSTIFICATION : Recherche par nom (admin interface)
CREATE INDEX IF NOT EXISTS idx_categories_name ON categories (name)
WHERE
    is_active = true;

-- RLS JUSTIFICATION : Lecture publique des catégories actives
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY categories_read_active ON categories FOR
SELECT USING (is_active = true);

CREATE POLICY admin_manage_categories ON categories FOR ALL TO admin_bookstore USING (true);

-- -----------------------------------------------------
-- TABLE : products (MISE À JOUR AVEC CITEXT + MÉTADONNÉES LIVRES)
-- -----------------------------------------------------
-- RÔLE MÉTIER : Catalogue produits avec recherche insensible à la casse
-- RELATIONS :
--   └─ tax_rates 1:N products (calcul TVA)
--   └─ users(admin) 1:N products (créateur)
--   └─ products N:M categories (via product_categories)
--   └─ products 1:N product_images (galerie)
--   └─ products 1:N cart_items (ajout panier)
--   └─ products 1:N order_items (commandes)

CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    -- === IDENTIFICATION (CITEXT pour recherche) ===
    name CITEXT NOT NULL,                          -- Nom produit - RECHERCHE insensible casse
    slug CITEXT UNIQUE NOT NULL,                   -- URL unique (SEO) - CITEXT évite doublons casse
    sku VARCHAR(100) UNIQUE,                       -- Référence unique interne (format strict)
    -- === MÉTADONNÉES LIVRES CULINAIRES ===
    author CITEXT,                                 -- Auteur - RECHERCHE par nom auteur
    isbn VARCHAR(17) UNIQUE,                       -- ISBN-13 international (format: 978-2-123456-78-9)
    page_count INTEGER,                            -- Nombre de pages
    publication_year INTEGER,                      -- Année de publication
    language VARCHAR(10) DEFAULT 'fr',             -- Langue (fr/en/es/etc.)
    publisher CITEXT,                              -- Éditeur - RECHERCHE par maison d'édition
    -- === CATALOGUE ===
    short_description TEXT,                        -- Résumé pour listings (TEXT pour flexibilité)
    description TEXT,                              -- Description complète
    -- === PRIX (CENTIMES pour précision) ===
    price_cents INTEGER NOT NULL,                  -- Prix en centimes HT
    tax_rate_id INTEGER NOT NULL,                  -- Taux TVA applicable
    -- === STOCK ===
    stock_quantity INTEGER NOT NULL DEFAULT 0,     -- Quantité disponible
    low_stock_threshold INTEGER DEFAULT 10,        -- Seuil alerte stock bas
    manage_stock BOOLEAN DEFAULT TRUE,             -- Gérer le stock ou non
    -- === SEO ===
    meta_title CITEXT,                             -- Titre page produit - peut contenir titre recherché
    meta_description TEXT,                         -- Meta description
    -- === STATUT ===
    is_active BOOLEAN DEFAULT TRUE,                -- Produit visible
    is_featured BOOLEAN DEFAULT FALSE,             -- Produit mis en avant
    -- === AUDIT ===
    created_by INTEGER NOT NULL,                   -- Admin créateur
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- === CONTRAINTES MÉTIER ===
    CONSTRAINT products_price_positive CHECK (price_cents > 0),
    CONSTRAINT products_stock_positive CHECK (stock_quantity >= 0),
    CONSTRAINT products_page_count_positive CHECK (page_count IS NULL OR page_count > 0),
    CONSTRAINT products_valid_year CHECK (
        publication_year IS NULL OR
        (publication_year >= 1900 AND publication_year <= EXTRACT(YEAR FROM CURRENT_DATE) + 2)
    ),
    CONSTRAINT products_valid_language CHECK (
        language IN ('fr', 'en', 'es', 'it', 'de', 'pt', 'zh', 'ja', 'ar', 'other')
    ),
    CONSTRAINT products_valid_slug CHECK (
        slug ~ '^[a-z0-9]([a-z0-9\-]*[a-z0-9])?$'
        AND char_length(slug) BETWEEN 3 AND 200
    ),
    CONSTRAINT products_valid_isbn CHECK (
        isbn IS NULL OR isbn ~ '^97[89]-\d{1,5}-\d{1,7}-\d{1,7}-\d$'  -- Format ISBN-13
    ),
    -- === CONTRAINTES DE RÉFÉRENCE ===
    CONSTRAINT fk_products_tax_rate FOREIGN KEY (tax_rate_id)
        REFERENCES tax_rates (id),
    CONSTRAINT fk_products_created_by FOREIGN KEY (created_by)
        REFERENCES users (id)
);

-- =====================================================
-- INDEX OPTIMISÉS POUR RECHERCHE E-COMMERCE
-- =====================================================

-- JUSTIFICATION : Recherche produits par nom (barre de recherche principale)
CREATE INDEX idx_products_name_search ON products USING gin (name gin_trgm_ops)
    WHERE is_active = true;

-- JUSTIFICATION : Recherche par auteur (filtre fréquent livres culinaires)
CREATE INDEX idx_products_author_search ON products USING gin (author gin_trgm_ops)
    WHERE is_active = true AND author IS NOT NULL;

-- JUSTIFICATION : Recherche par éditeur (navigation par maison d'édition)
CREATE INDEX idx_products_publisher_search ON products USING gin (publisher gin_trgm_ops)
    WHERE is_active = true AND publisher IS NOT NULL;

-- JUSTIFICATION : Index fonctionnels standards pour API
CREATE INDEX idx_products_tax_rate ON products (tax_rate_id);           -- Calculs TVA
CREATE INDEX idx_products_active ON products (is_active);               -- Produits visibles
CREATE INDEX idx_products_slug ON products (slug);                      -- Page produit SEO
CREATE INDEX idx_products_created_by ON products (created_by);          -- Produits par admin
CREATE INDEX idx_products_featured ON products (is_featured);           -- Produits vedettes
CREATE INDEX idx_products_stock ON products (stock_quantity);           -- Gestion stock

-- JUSTIFICATION : Index composites pour filtres e-commerce fréquents
CREATE INDEX idx_products_active_price ON products (is_active, price_cents)
    WHERE is_active = true;                                             -- Tri prix sur actifs

CREATE INDEX idx_products_featured_active ON products (is_featured, is_active)
    WHERE is_featured = true AND is_active = true;                      -- Produits vedettes

CREATE INDEX idx_products_year_active ON products (publication_year DESC, is_active)
    WHERE is_active = true AND publication_year IS NOT NULL;            -- Nouveautés par année

CREATE INDEX idx_products_language_active ON products (language, is_active)
    WHERE is_active = true;                                             -- Filtres par langue

-- JUSTIFICATION : Recherche ISBN (validation unicité + recherche exacte)
CREATE UNIQUE INDEX idx_products_isbn ON products (isbn)
    WHERE isbn IS NOT NULL;

-- =====================================================
-- RLS : ROW LEVEL SECURITY
-- =====================================================
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- JUSTIFICATION : Lecture publique des produits actifs uniquement
CREATE POLICY products_read_active ON products FOR SELECT
    USING (is_active = true);

-- JUSTIFICATION : Admins gèrent tous les produits
CREATE POLICY admin_manage_products ON products FOR ALL TO admin_bookstore
    USING (true);

-- JUSTIFICATION : Service API accès technique complet
CREATE POLICY api_service_full_products ON products FOR ALL TO api_service_bookstore
    USING (true);


/* TODO: Ajout de la table product_categories (PIVOT N:M) */
-- -----------------------------------------------------
-- TABLE : product_categories (PIVOT N:M)
-- -----------------------------------------------------
-- RÔLE MÉTIER : Relation many-to-many entre produits et catégories
--               Permet classification multiple (région + type + marketing)
-- RELATIONS :
--   └─ products 1:N product_categories (un produit dans plusieurs catégories)
--   └─ categories 1:N product_categories (une catégorie contient plusieurs produits)
--   └─ products N:M categories (via cette table pivot)

CREATE TABLE product_categories (
    -- === CLÉS PRIMAIRES COMPOSITES ===
    product_id INTEGER NOT NULL,                   -- FK vers products - Produit classifié
    category_id INTEGER NOT NULL,                  -- FK vers categories - Catégorie de classification
    -- === MÉTADONNÉES DE RELATION ===
    is_primary BOOLEAN DEFAULT FALSE,              -- TRUE = catégorie principale pour navigation/SEO
    sort_order INTEGER DEFAULT 0,                  -- Ordre d'affichage dans liste catégories produit
    -- === AUDIT STANDARD ===
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Date d'ajout de cette classification
    -- === CONTRAINTES MÉTIER ===
    CONSTRAINT product_categories_sort_positive CHECK (sort_order >= 0),
    -- === CONTRAINTES DE RÉFÉRENCE ===
    CONSTRAINT fk_product_categories_product
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,  -- Supprime classifications si produit supprimé
    CONSTRAINT fk_product_categories_category
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE, -- Supprime classifications si catégorie supprimée
    -- === CLÉ PRIMAIRE COMPOSITE ===
    PRIMARY KEY (product_id, category_id)          -- Évite doublons (même produit, même catégorie)
);

-- JUSTIFICATION INDEX : Une seule catégorie principale par produit (règle métier critique)
-- Exemple : "Guide Thaï" peut être dans [Asie(PRIMARY), Guides, Nouveautés] mais une seule PRIMARY
CREATE UNIQUE INDEX idx_one_primary_per_product
    ON product_categories (product_id)
    WHERE is_primary = TRUE;

-- JUSTIFICATION INDEX : Recherche catégories d'un produit (page produit, breadcrumbs)
CREATE INDEX idx_product_categories_product
    ON product_categories (product_id, sort_order);

-- JUSTIFICATION INDEX : Recherche produits d'une catégorie (pages catégories, filtres)
CREATE INDEX idx_product_categories_category
    ON product_categories (category_id);

-- JUSTIFICATION INDEX : Recherche catégories principales uniquement (navigation principale)
CREATE INDEX idx_product_categories_primary
    ON product_categories (category_id)
    WHERE is_primary = TRUE;

-- RLS JUSTIFICATION : Classifications visibles publiquement, gestion admin uniquement
ALTER TABLE product_categories ENABLE ROW LEVEL SECURITY;

-- Politique lecture : Toutes les classifications visibles (pour navigation/filtres)
CREATE POLICY product_categories_read_all ON product_categories
    FOR SELECT USING (true);

-- Politique gestion : Seuls admins peuvent modifier classifications
CREATE POLICY admin_manage_classifications ON product_categories
    FOR ALL TO admin_bookstore USING (true);

-- EXPLICATION CHOIX TECHNIQUES :
-- 1. CASCADE DELETE : Si produit/catégorie supprimé, classifications automatiquement nettoyées
-- 2. is_primary : Détermine catégorie pour URL SEO (/categories/{primary_category}/{product_slug})
-- 3. sort_order : Contrôle ordre affichage tags catégories sur fiche produit
-- 4. Clé composite : Évite qu'un produit soit deux fois dans même catégorie
-- 5. Index partiel WHERE : Optimise recherches catégories principales uniquement


/* TODO: Ajout de la table product_reviews (VERSION ANONYMISATION)*/
-- -----------------------------------------------------
-- TABLE : product_reviews (VERSION ANONYMISATION)
-- -----------------------------------------------------
-- RÔLE MÉTIER : Stockage des avis clients avec préservation anonyme
-- RELATIONS :
--   └─ products 1:N product_reviews (un produit a plusieurs avis)
--   └─ users 1:N product_reviews (relation nullable pour anonymisation)

CREATE TABLE product_reviews (
    id SERIAL PRIMARY KEY,                         -- PK auto-incrémentée
    -- === RELATIONS ===
    product_id INTEGER NOT NULL ,                                           -- FK produit (obligatoire)
    user_id INTEGER,                                                        -- FK utilisateur (nullable pour anonyme)
    -- === IDENTIFICATION ANONYME ===
    anonymous_name VARCHAR(100),                                            -- "Utilisateur anonyme" ou nom généré
    -- === CONTENU AVIS ===
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),                 -- Note 1-5 étoiles (obligatoire)
    title VARCHAR(200),                                                      -- Titre avis (optionnel)
    comment TEXT,                                                            -- Commentaire détaillé (optionnel)
    -- === MÉTADONNÉES ===
    is_verified_purchase BOOLEAN DEFAULT FALSE,                             -- Achat vérifié (conservé même anonyme)
    is_moderated BOOLEAN DEFAULT FALSE,                                      -- Modéré par admin
    is_published BOOLEAN DEFAULT TRUE,                                       -- Visible publiquement
    is_anonymous BOOLEAN DEFAULT FALSE,                                      -- Marqueur utilisateur supprimé
    -- === AUDIT STANDARD ===
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,                          -- Date création
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,                          -- Dernière modification
    anonymized_at TIMESTAMP,                                                 -- Date anonymisation
    -- === CONTRAINTES MÉTIER ===
    CONSTRAINT reviews_user_or_anonymous CHECK (
        (user_id IS NOT NULL AND is_anonymous = FALSE) OR
        (user_id IS NULL AND is_anonymous = TRUE AND anonymous_name IS NOT NULL)
    ),
    -- === CONTRAINTES DE RÉFÉRENCE ===
    CONSTRAINT fk_reviews_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    CONSTRAINT fk_reviews_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- JUSTIFICATION INDEX :
CREATE INDEX idx_reviews_product_id ON product_reviews(product_id);        -- Récupération rapide avis d'un produit
CREATE INDEX idx_reviews_user_id ON product_reviews(user_id) WHERE user_id IS NOT NULL; -- Historique utilisateur actif
CREATE INDEX idx_reviews_rating ON product_reviews(rating);                -- Filtrage par note
CREATE INDEX idx_reviews_created_at ON product_reviews(created_at DESC);   -- Tri chronologique récent
CREATE INDEX idx_reviews_published ON product_reviews(is_published) WHERE is_published = TRUE; -- Avis visibles

-- JUSTIFICATION RLS :
ALTER TABLE product_reviews ENABLE ROW LEVEL SECURITY;

-- Lecture publique des avis publiés
CREATE POLICY reviews_read_published ON product_reviews
    FOR SELECT
    USING (is_published = true);  -- ← Seuls avis publiés visibles

-- Admin gère tout
CREATE POLICY admin_manage_reviews ON product_reviews
    FOR ALL TO admin_bookstore
    USING (true);

-- Customers peuvent créer/modifier leurs avis
CREATE POLICY customers_manage_reviews ON product_reviews
    FOR ALL TO customer_bookstore
    USING (true);

-- -----------------------------------------------------
-- TABLE : product_images
-- -----------------------------------------------------
-- RÔLE MÉTIER : Galerie d'images par produit avec image principale
-- RELATIONS :
--   └─ products 1:N product_images (galerie)
--   └─ users(admin) 1:N product_images (qui a uploadé)

CREATE TABLE IF NOT EXISTS product_images (
    id SERIAL PRIMARY KEY,
    -- === RELATIONS ===
    product_id INTEGER NOT NULL,                   -- Produit parent
    -- === IMAGE ===
    image_url VARCHAR(500) NOT NULL,               -- URL image stockée
    alt_text VARCHAR(200),                         -- Texte alternatif (SEO + accessibilité)
    is_primary BOOLEAN DEFAULT FALSE,              -- Image principale du produit
    -- === ORDRE AFFICHAGE ===
    sort_order INTEGER DEFAULT 0,                  -- Ordre dans la galerie
    -- === AUDIT ===
    uploaded_by INTEGER NOT NULL,                  -- Admin qui a uploadé
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- === CONTRAINTES MÉTIER ===
    CONSTRAINT product_images_sort_positive CHECK (sort_order >= 0),
    CONSTRAINT product_images_url_not_empty CHECK (char_length(trim(image_url)) > 0),
    -- === CONTRAINTES DE RÉFÉRENCE ===
    CONSTRAINT fk_product_images_product FOREIGN KEY (product_id)
        REFERENCES products (id) ON DELETE CASCADE,
    CONSTRAINT fk_product_images_uploaded_by FOREIGN KEY (uploaded_by)
        REFERENCES users (id)
);

-- CONTRAINTE CRITIQUE : Une seule image primary par produit
CREATE UNIQUE INDEX idx_product_images_one_primary
    ON product_images (product_id)
    WHERE is_primary = true;

-- INDEX JUSTIFICATION : Galerie produit et performance
CREATE INDEX IF NOT EXISTS idx_product_images_product ON product_images (product_id);                    -- Galerie produit
CREATE INDEX IF NOT EXISTS idx_product_images_product_order ON product_images (product_id, sort_order); -- Ordre affichage
CREATE INDEX IF NOT EXISTS idx_product_images_uploaded_by ON product_images (uploaded_by);              -- Images par admin

-- RLS JUSTIFICATION : Images publiques, gestion admin
ALTER TABLE product_images ENABLE ROW LEVEL SECURITY;

CREATE POLICY images_read_all ON product_images FOR SELECT
    USING (true);

CREATE POLICY admin_manage_images ON product_images FOR ALL TO admin_bookstore
    USING (true);


-- =====================================================
-- THÈME : GESTION UTILISATEUR
-- =====================================================
-- JUSTIFICATION : Données clients pour livraisons et préférences
-- ENDPOINTS LIÉS :
-- - GET /api/v1/addresses
-- - POST /api/v1/addresses
-- - PUT /api/v1/addresses/:id/default
-- TABLES : addresses, cart_items

-- -----------------------------------------------------
-- TABLE : addresses
-- -----------------------------------------------------
-- RÔLE MÉTIER : Adresses de livraison et facturation clients
-- RELATIONS :
--   └─ users(customer) 1:N addresses (adresses multiples)
--   └─ addresses 1:N orders (adresse de livraison/facturation)

CREATE TABLE IF NOT EXISTS addresses (
    id SERIAL PRIMARY KEY,
    -- === RELATIONS ===
    user_id INTEGER NOT NULL,                      -- Propriétaire adresse
    -- === TYPE ADRESSE ===
    type VARCHAR(20) DEFAULT 'shipping',           -- Type d'adresse
    -- === CONTACT ===
    first_name VARCHAR(100) NOT NULL,              -- Prénom destinataire
    last_name VARCHAR(100) NOT NULL,               -- Nom destinataire
    company VARCHAR(150),                          -- Entreprise (optionnel)
    phone VARCHAR(20) NOT NULL,                    -- Téléphone livraison
    -- === ADRESSE FRANÇAISE ===
    address_line_1 VARCHAR(200) NOT NULL,         -- Numéro et rue
    address_line_2 VARCHAR(200),                  -- Complément (bâtiment, etc.)
    city VARCHAR(100) NOT NULL,                   -- Ville
    postal_code VARCHAR(10) NOT NULL,             -- Code postal
    state_region VARCHAR(100),                    -- Région/département
    country CHAR(2) DEFAULT 'FR',                 -- Code pays ISO
    -- === PRÉFÉRENCES ===
    is_default BOOLEAN DEFAULT FALSE,             -- Adresse par défaut
    -- === AUDIT ===
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- === CONTRAINTES MÉTIER ===
    CONSTRAINT addresses_valid_type CHECK (
        type IN ('shipping', 'billing', 'both')
    ),
    CONSTRAINT addresses_valid_postal_fr CHECK (
        country != 'FR' OR postal_code ~ '^[0-9]{5}$'
    ),
    CONSTRAINT addresses_valid_phone CHECK (
        phone ~ '^\+?[0-9\s\-\.]{10,15}$'
    ),
    CONSTRAINT addresses_valid_country CHECK (
        char_length(country) = 2
    ),
    CONSTRAINT addresses_names_not_empty CHECK (
        char_length(trim(first_name)) > 0 AND char_length(trim(last_name)) > 0
    ),
    -- === CONTRAINTES DE RÉFÉRENCE ===
    CONSTRAINT fk_addresses_user FOREIGN KEY (user_id)
        REFERENCES users (id) ON DELETE CASCADE
);

-- CONTRAINTE CRITIQUE : Une seule adresse par défaut par utilisateur ET par type
CREATE UNIQUE INDEX idx_addresses_one_default_per_type
    ON addresses (user_id, type)
    WHERE is_default = true;

-- INDEX JUSTIFICATION : Performance endpoints utilisateur
CREATE INDEX IF NOT EXISTS idx_addresses_user ON addresses (user_id);                    -- Adresses utilisateur
CREATE INDEX IF NOT EXISTS idx_addresses_user_type ON addresses (user_id, type);         -- Filtrer par type
CREATE INDEX IF NOT EXISTS idx_addresses_country ON addresses (country);                 -- Stats par pays

-- RLS JUSTIFICATION : Adresses privées par utilisateur
ALTER TABLE addresses ENABLE ROW LEVEL SECURITY;

-- Customers peuvent gérer leurs adresses
CREATE POLICY customers_manage_addresses ON addresses
    FOR ALL TO customer_bookstore
    USING (true);  -- ← RLS simple

-- Admin voit toutes les adresses
CREATE POLICY admin_view_addresses ON addresses
    FOR SELECT TO admin_bookstore
    USING (true);


-- -----------------------------------------------------
-- TABLE : cart_items
-- -----------------------------------------------------
-- RÔLE MÉTIER : Panier persistant pour chaque utilisateur connecté
-- RELATIONS :
--   └─ users(customer) 1:N cart_items (panier multi-produits)
--   └─ products 1:N cart_items (référence produit)

CREATE TABLE IF NOT EXISTS cart_items (
    id SERIAL PRIMARY KEY,
    -- === RELATIONS ===
    user_id INTEGER NOT NULL,                      -- Propriétaire panier
    product_id INTEGER NOT NULL,                   -- Produit dans panier
    -- === CONTENU PANIER ===
    quantity INTEGER NOT NULL,                     -- Quantité souhaitée
    -- === HISTORIQUE ===
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Quand ajouté au panier
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Dernière modification quantité
    -- === CONTRAINTES MÉTIER ===
    CONSTRAINT cart_items_quantity_positive CHECK (quantity > 0),
    CONSTRAINT cart_items_quantity_reasonable CHECK (quantity <= 999), -- Limite anti-spam
    -- === CONTRAINTES UNICITÉ ===
    CONSTRAINT cart_items_unique_user_product UNIQUE(user_id, product_id), -- Un produit une fois par panier
    -- === CONTRAINTES DE RÉFÉRENCE ===
    CONSTRAINT fk_cart_items_user FOREIGN KEY (user_id)
        REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT fk_cart_items_product FOREIGN KEY (product_id)
        REFERENCES products (id) ON DELETE CASCADE
);

-- INDEX JUSTIFICATION : Performance panier et gestion stock
CREATE INDEX IF NOT EXISTS idx_cart_items_user ON cart_items (user_id);                    -- Panier utilisateur
CREATE INDEX IF NOT EXISTS idx_cart_items_product ON cart_items (product_id);              -- Produits populaires + stock
CREATE INDEX IF NOT EXISTS idx_cart_items_updated ON cart_items (updated_at);              -- Nettoyage paniers anciens

-- RLS JUSTIFICATION : Panier privé par utilisateur
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;

-- Customers gèrent leurs paniers
CREATE POLICY customers_manage_cart ON cart_items
    FOR ALL TO customer_bookstore
    USING (true);

-- Admin voit tous les paniers
CREATE POLICY admin_view_cart ON cart_items
    FOR SELECT TO admin_bookstore
    USING (true);

-- -----------------------------------------------------
-- TABLE : orders
-- -----------------------------------------------------
-- RÔLE MÉTIER : Commandes clients avec calculs prix figés et statut suivi
-- RELATIONS :
--   └─ users(customer) 1:N orders (historique commandes)
--   └─ addresses N:1 orders (livraison/facturation)
--   └─ orders 1:N order_items (lignes commande)

CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    -- === IDENTIFICATION ===
    order_number VARCHAR(50) UNIQUE NOT NULL,      -- Numéro commande client (ex: ORD-20250127-001)
    -- === RELATIONS ===
    user_id INTEGER NOT NULL,                      -- Client propriétaire
    shipping_address_id INTEGER,                   -- Adresse livraison (snapshot)
    billing_address_id INTEGER,                    -- Adresse facturation (snapshot)
    -- === STATUT COMMANDE ===
    status VARCHAR(20) DEFAULT 'pending',          -- État commande
    -- === CALCULS PRIX FIGÉS (en centimes) ===
    subtotal_cents INTEGER NOT NULL,               -- Sous-total HT
    tax_amount_cents INTEGER NOT NULL,             -- Total TVA
    shipping_cents INTEGER DEFAULT 0,              -- Frais port
    total_cents INTEGER NOT NULL,                  -- Total TTC
    -- === PAIEMENT EXTERNE ===
    payment_status VARCHAR(20) DEFAULT 'pending',  -- État paiement
    payment_method VARCHAR(50),                    -- Ex: "stripe", "paypal"
    payment_reference VARCHAR(200),                -- Référence externe (Stripe payment_intent)
    -- === LIVRAISON ===
    shipping_method VARCHAR(100),                  -- Mode livraison choisi
    tracking_number VARCHAR(100),                  -- Numéro suivi transporteur
    -- === NOTES ===
    customer_notes TEXT,                           -- Notes client à la commande
    admin_notes TEXT,                              -- Notes internes admin
    -- === AUDIT ===
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    shipped_at TIMESTAMP,                          -- Date expédition
    delivered_at TIMESTAMP,                        -- Date livraison
    -- === CONTRAINTES MÉTIER ===
    CONSTRAINT orders_status_valid CHECK (
        status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded')
    ),
    CONSTRAINT orders_payment_status_valid CHECK (
        payment_status IN ('pending', 'paid', 'failed', 'refunded')
    ),
    CONSTRAINT orders_subtotal_positive CHECK (subtotal_cents >= 0),
    CONSTRAINT orders_tax_positive CHECK (tax_amount_cents >= 0),
    CONSTRAINT orders_shipping_positive CHECK (shipping_cents >= 0),
    CONSTRAINT orders_total_positive CHECK (total_cents > 0),
    CONSTRAINT orders_total_calculation CHECK (
        total_cents = subtotal_cents + tax_amount_cents + shipping_cents
    ),
    CONSTRAINT orders_order_number_format CHECK (
        order_number ~* '^[A-Z]{3}-[0-9]{8}-[0-9]{3}$'
    ),
    -- === CONTRAINTES LOGIQUES ===
    CONSTRAINT orders_shipped_requires_date CHECK (
        status != 'shipped' OR shipped_at IS NOT NULL
    ),
    CONSTRAINT orders_delivered_requires_dates CHECK (
        status != 'delivered' OR (shipped_at IS NOT NULL AND delivered_at IS NOT NULL)
    ),
    CONSTRAINT orders_tracking_when_shipped CHECK (
        status NOT IN ('shipped', 'delivered') OR tracking_number IS NOT NULL
    ),
    -- === CONTRAINTES DE RÉFÉRENCE ===
    CONSTRAINT fk_orders_user FOREIGN KEY (user_id)
        REFERENCES users (id) ON DELETE RESTRICT,  -- Préserver historique
    CONSTRAINT fk_orders_shipping_address FOREIGN KEY (shipping_address_id)
        REFERENCES addresses (id) ON DELETE SET NULL,
    CONSTRAINT fk_orders_billing_address FOREIGN KEY (billing_address_id)
        REFERENCES addresses (id) ON DELETE SET NULL
);

-- INDEX JUSTIFICATION : Performance recherche commandes multi-critères
CREATE INDEX IF NOT EXISTS idx_orders_user ON orders (user_id);                           -- Historique client
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders (status);                          -- Dashboard admin
CREATE INDEX IF NOT EXISTS idx_orders_payment_status ON orders (payment_status);          -- Suivi paiements
CREATE INDEX IF NOT EXISTS idx_orders_date ON orders (created_at);                        -- Tri chronologique
CREATE INDEX IF NOT EXISTS idx_orders_user_date ON orders (user_id, created_at DESC);     -- Historique client optimisé
CREATE INDEX IF NOT EXISTS idx_orders_status_date ON orders (status, created_at);         -- Admin filtres combinés

-- CONSTRAINT UNIQUE après les index pour cohérence
CREATE UNIQUE INDEX idx_orders_number_unique ON orders (order_number);      -- Numérotation unique

-- RLS JUSTIFICATION : Commandes privées par client
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- Customers peuvent consulter leurs commandes
CREATE POLICY customers_view_orders ON orders
    FOR SELECT TO customer_bookstore
    USING (true);

-- Admin gère toutes les commandes
CREATE POLICY admin_manage_orders ON orders
    FOR ALL TO admin_bookstore
    USING (true);

-- -----------------------------------------------------
-- TABLE : order_items
-- -----------------------------------------------------
-- RÔLE MÉTIER : Lignes de commande avec snapshot produit immutable
-- RELATIONS :
--   └─ orders 1:N order_items (détail commande)
--   └─ products N:1 order_items (référence produit - peut changer)

CREATE TABLE IF NOT EXISTS order_items (
    id SERIAL PRIMARY KEY,
    -- === RELATIONS ===
    order_id INTEGER NOT NULL,                         -- Commande parente
    product_id INTEGER,                                -- Référence produit (peut être NULL si supprimé)
    -- === SNAPSHOT PRODUIT (au moment commande - IMMUTABLE) ===
    product_name VARCHAR(200) NOT NULL,               -- Nom à ce moment
    product_sku VARCHAR(100),                         -- SKU à ce moment
    unit_price_cents INTEGER NOT NULL,               -- Prix unitaire HT
    tax_rate DECIMAL(5,4) NOT NULL DEFAULT 0.2000,   -- Taux TVA à ce moment (20% par défaut)
    -- === QUANTITÉ ET CALCULS ===
    quantity INTEGER NOT NULL,                        -- Quantité commandée
    line_subtotal_cents INTEGER NOT NULL,            -- unit_price * quantity
    line_tax_cents INTEGER NOT NULL,                 -- line_subtotal * tax_rate
    line_total_cents INTEGER NOT NULL,               -- subtotal + tax
    -- === CONTRAINTES MÉTIER ===
    CONSTRAINT order_items_unit_price_positive CHECK (unit_price_cents > 0),
    CONSTRAINT order_items_quantity_positive CHECK (quantity > 0),
    CONSTRAINT order_items_quantity_reasonable CHECK (quantity <= 999),
    CONSTRAINT order_items_tax_rate_valid CHECK (tax_rate >= 0 AND tax_rate <= 1),
    CONSTRAINT order_items_subtotal_positive CHECK (line_subtotal_cents >= 0),
    CONSTRAINT order_items_tax_positive CHECK (line_tax_cents >= 0),
    CONSTRAINT order_items_total_positive CHECK (line_total_cents > 0),
    -- === CONTRAINTES CALCULS ===
    CONSTRAINT order_items_line_calculations CHECK (
        line_subtotal_cents = unit_price_cents * quantity AND
        line_tax_cents = ROUND(line_subtotal_cents * tax_rate) AND
        line_total_cents = line_subtotal_cents + line_tax_cents
    ),
    -- === CONTRAINTES DE RÉFÉRENCE ===
    CONSTRAINT fk_order_items_order FOREIGN KEY (order_id)
        REFERENCES orders (id) ON DELETE CASCADE,
    CONSTRAINT fk_order_items_product FOREIGN KEY (product_id)
        REFERENCES products (id) ON DELETE SET NULL    -- Préserver historique si produit supprimé
);

-- INDEX JUSTIFICATION : Performance requêtes détail commandes
CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items (order_id);              -- Détail commande
CREATE INDEX IF NOT EXISTS idx_order_items_product ON order_items (product_id)           -- Analyse ventes par produit
    WHERE product_id IS NOT NULL;                                          -- Index partiel
CREATE INDEX IF NOT EXISTS idx_order_items_sku ON order_items (product_sku)              -- Recherche par SKU historique
    WHERE product_sku IS NOT NULL;                                         -- Index partiel

-- RLS JUSTIFICATION : Accès via la commande parente
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- Customers peuvent consulter leurs items de commande
CREATE POLICY customers_view_order_items ON order_items
    FOR SELECT TO customer_bookstore
    USING (true);

-- Admin gère tous les items
CREATE POLICY admin_manage_order_items ON order_items
    FOR ALL TO admin_bookstore
    USING (true);
