-- =====================================================
-- VUES E-COMMERCE - VERSION DONNÉES PLATES OPTIMISÉE
-- PRINCIPE : PostgreSQL = relations pures, Node.js = logique
-- ARCHITECTURE : Séparation claire des responsabilités
-- - Chaque vue = 1 use case métier précis
-- - Données plates pour faciliter le cache et les transformations
-- - JOINs nécessaires uniquement pour éviter N+1 queries
-- =====================================================
-- -----------------------------------------------------
-- VUE 1 : user_profiles_complete
-- -----------------------------------------------------
-- RÔLE MÉTIER : Profils utilisateurs complets (authentification + données personnelles)
-- ENDPOINTS LIÉS :
--   • GET /api/v1/profile (profil utilisateur connecté)
--   • GET /api/v1/admin/users (liste utilisateurs admin)
--   • PUT /api/v1/profile (mise à jour profil)
-- JUSTIFICATION : Évite JOIN côté Node.js pour données utilisateur de base
CREATE
OR REPLACE VIEW user_profiles_complete AS
SELECT
    -- === IDENTIFICATION ===
    u.id AS user_id,
    u.email,
    ur.role_name,
    -- === DONNÉES PERSONNELLES ===
    up.first_name,
    up.last_name,
    CONCAT (up.first_name, ' ', up.last_name) AS full_name, -- Pré-calculé pour affichage
    up.phone,
    up.birth_date,
    up.newsletter_consent,
    up.avatar_url,
    -- === AUDIT ===
    u.created_at AS user_since,
    up.updated_at AS profile_updated_at
FROM
    users u
    LEFT JOIN user_roles ur ON u.role_id = ur.id
    LEFT JOIN user_profiles up ON u.id = up.user_id
ORDER BY
    u.created_at DESC;

-- EXPLICATION TECHNIQUE :
-- LEFT JOIN car user_profiles peut être null (profil non complété)
-- -----------------------------------------------------
-- VUE 2 : user_addresses
-- -----------------------------------------------------
-- RÔLE MÉTIER : Adresses utilisateurs avec destinataire (pour checkout/livraisons)
-- ENDPOINTS LIÉS :
--   • GET /api/v1/user/addresses (sélection adresse checkout)
--   • GET /api/v1/admin/addresses (gestion admin)
--   • POST /api/v1/orders (création commande avec adresse)
-- JUSTIFICATION : Inclut les infos destinataire pour éviter un JOIN supplémentaire
-- lors de l'affichage des adresses ou génération d'étiquettes
CREATE
OR REPLACE VIEW user_addresses AS
SELECT
    -- === ADRESSE ===
    a.id AS address_id,
    a.user_id,
    a.type,
    a.address_line_1,
    a.address_line_2,
    a.city,
    a.postal_code,
    a.country,
    a.is_default,
    -- === DESTINATAIRE (pour factures/livraisons) ===
    up.first_name,
    up.last_name,
    CONCAT (up.first_name, ' ', up.last_name) AS full_name,
    up.phone, -- Essentiel pour transporteur
    u.email, -- Contact livraison
    -- === AUDIT ===
    a.created_at,
    a.updated_at
FROM
    addresses a
    JOIN users u ON a.user_id = u.id
    LEFT JOIN user_profiles up ON u.id = up.user_id -- LEFT car profil peut être incomplet
ORDER BY
    a.user_id,
    a.is_default DESC, -- Adresse par défaut en premier
    a.created_at ASC;

-- EXPLICATION TECHNIQUE :
-- JOIN users obligatoire car chaque adresse a un propriétaire
-- LEFT JOIN user_profiles car first_name/last_name peuvent être null
-- EXPLICATION TECHNIQUE :
-- LEFT JOIN products car le produit peut avoir été supprimé après commande
-- Garde les données figées (product_name, unit_price_cents) + données actuelles
-- -----------------------------------------------------
-- VUE 3 : products_catalog
-- -----------------------------------------------------
-- RÔLE MÉTIER : Catalogue produits actifs pour navigation client
-- ENDPOINTS LIÉS :
--   • GET /api/v1/products (liste produits)
--   • GET /api/v1/products/featured (produits mis en avant)
--   • GET /api/v1/search?q=... (recherche produits)
-- JUSTIFICATION : Filtre activé par défaut, ordre par featured puis date
CREATE
OR REPLACE VIEW products_catalog AS
SELECT
    -- === PRODUIT ===
    p.id AS product_id,
    p.name,
    p.slug,
    p.sku,
    p.author,
    p.isbn,
    p.page_count,
    p.publication_year,
    p.language,
    p.publisher,
    p.description,
    p.short_description,
    p.price_cents,
    p.stock_quantity,
    p.low_stock_threshold,
    p.is_active,
    p.is_featured,
    -- === SEO ===
    p.meta_title,
    p.meta_description,
    -- === AUDIT ===
    p.created_at,
    p.updated_at
FROM
    products p
WHERE
    p.is_active = TRUE
ORDER BY
    p.is_featured DESC,
    p.created_at DESC;

-- Puis par nouveauté
-- Puis par nouveauté
-- EXPLICATION TECHNIQUE :
-- Filtre WHERE is_active=TRUE pour éviter côté Node.js
-- Ordre optimisé pour affichage frontend (featured puis nouveautés)
-- -----------------------------------------------------
-- VUE 4 : product_images_list
-- -----------------------------------------------------
-- RÔLE MÉTIER : Images produits ordonnées (pour API séparée images)
-- ENDPOINTS LIÉS :
--   • GET /api/v1/products/:id/images (images d'un produit)
--   • GET /api/v1/admin/products/:id/images (gestion admin images)
-- JUSTIFICATION : Requête séparée pour éviter duplication dans product_catalog
-- Node.js peut choisir de charger les images ou non selon le besoin
CREATE
OR REPLACE VIEW product_images_list AS
SELECT
    -- === IMAGE ===
    pi.id AS image_id,
    pi.product_id,
    pi.image_url,
    pi.alt_text,
    pi.sort_order
FROM
    product_images pi
ORDER BY
    pi.product_id, -- Groupement par produit
    pi.sort_order ASC;

-- Ordre d'affichage
-- Ordre d'affichage
-- EXPLICATION TECHNIQUE :
-- Vue simple sans JOIN pour performance (utilisée souvent)
-- Ordre par sort_order pour affichage carousel/galerie
-- -----------------------------------------------------
-- VUE 5 : product_categories_list
-- -----------------------------------------------------
-- RÔLE MÉTIER : Relations produits-catégories avec noms catégories
-- ENDPOINTS LIÉS :
--   • GET /api/v1/products/:id/categories (catégories d'un produit)
--   • GET /api/v1/categories/:slug/products (produits d'une catégorie)
-- JUSTIFICATION : Inclut le nom catégorie pour éviter JOIN côté Node.js
-- Distinction catégorie primaire vs secondaires pour SEO
CREATE
OR REPLACE VIEW product_categories_list AS
SELECT
    -- === RELATION ===
    pc.product_id,
    pc.category_id,
    pc.is_primary, -- Catégorie principale (SEO)
    pc.sort_order,
    -- === CATÉGORIE (pour éviter JOIN côté API) ===
    c.name AS category_name,
    c.slug AS category_slug,
    c.parent_id AS category_parent_id, -- Hiérarchie catégorie
    -- === AUDIT ===
    pc.created_at
FROM
    product_categories pc
    JOIN categories c ON pc.category_id = c.id
ORDER BY
    pc.product_id, -- Groupement par produit
    pc.is_primary DESC, -- Catégorie primaire d'abord
    pc.sort_order ASC;

-- Puis ordre défini
-- EXPLICATION TECHNIQUE :
-- JOIN categories obligatoire car on a besoin du nom pour affichage
-- Ordre is_primary DESC pour avoir la catégorie principale en premier
-- -----------------------------------------------------
-- VUE 6 : orders_summary
-- -----------------------------------------------------
-- RÔLE MÉTIER : Résumé commandes avec client et adresses dénormalisées
-- ENDPOINTS LIÉS :
--   • GET /api/v1/orders (historique client)
--   • GET /api/v1/admin/orders (gestion admin)
--   • GET /api/v1/orders/:id (détail commande)
-- JUSTIFICATION : Pré-calcule les JOINs vers addresses pour performance
-- Évite 3 requêtes séparées (order + shipping_address + billing_address)
CREATE
OR REPLACE VIEW orders_summary AS
SELECT
    -- === COMMANDE ===
    o.id AS order_id,
    o.order_number,
    o.user_id,
    o.status,
    o.payment_status,
    o.total_cents,
    o.shipping_method,
    o.tracking_number,
    -- === DATES IMPORTANTES ===
    o.created_at AS order_date,
    o.shipped_at,
    o.delivered_at,
    -- === CLIENT ===
    CONCAT (up.first_name, ' ', up.last_name) AS customer_name,
    u.email AS customer_email,
    -- === ADRESSE LIVRAISON (dénormalisée pour performance) ===
    sa.address_line_1 AS shipping_address_line_1,
    sa.address_line_2 AS shipping_address_line_2,
    sa.city AS shipping_city,
    sa.postal_code AS shipping_postal_code,
    sa.country AS shipping_country,
    -- === ADRESSE FACTURATION ===
    ba.address_line_1 AS billing_address_line_1,
    ba.address_line_2 AS billing_address_line_2,
    ba.city AS billing_city,
    ba.postal_code AS billing_postal_code,
    ba.country AS billing_country
FROM
    orders o
    LEFT JOIN users u ON o.user_id = u.id
    LEFT JOIN user_profiles up ON u.id = up.user_id
    LEFT JOIN addresses sa ON o.shipping_address_id = sa.id -- Adresse livraison
    LEFT JOIN addresses ba ON o.billing_address_id = ba.id -- Adresse facturation
ORDER BY
    o.created_at DESC;

-- EXPLICATION TECHNIQUE :
-- LEFT JOIN addresses car shipping/billing peuvent être nulls temporairement
-- Dénormalisation volontaire pour éviter N+1 queries côté API
-- -----------------------------------------------------
-- VUE 7 : order_items_detailed
-- -----------------------------------------------------
-- RÔLE MÉTIER : Détails items commande avec infos produit (pour factures/exports)
-- ENDPOINTS LIÉS :
--   • GET /api/v1/orders/:id/items (détail items commande)
--   • GET /api/v1/admin/orders/:id/export (export facture)
-- JUSTIFICATION : Inclut les données produit actuelles pour comparaison prix
-- et affichage enrichi des items
CREATE
OR REPLACE VIEW order_items_detailed AS
SELECT
    -- === ITEM COMMANDE ===
    oi.id AS order_item_id,
    oi.order_id,
    oi.product_id,
    oi.product_name, -- Nom figé au moment commande
    oi.quantity,
    oi.unit_price_cents, -- Prix figé au moment commande
    oi.line_total_cents,
    -- === COMMANDE LIÉE ===
    o.order_number,
    o.status AS order_status,
    o.created_at AS order_date,
    -- === PRODUIT ACTUEL (pour comparaison) ===
    p.name AS current_product_name, -- Nom actuel (peut avoir changé)
    p.price_cents AS current_price_cents, -- Prix actuel (pour comparaison)
    p.is_active AS product_still_active, -- Produit toujours en vente ?
    p.stock_quantity AS current_stock -- Stock actuel
FROM
    order_items oi
    JOIN orders o ON oi.order_id = o.id
    LEFT JOIN products p ON oi.product_id = p.id -- LEFT car produit peut être supprimé
ORDER BY
    o.created_at DESC, -- Commandes récentes d'abord
    oi.id;

-- -----------------------------------------------------
-- VUE 8 : cart_items_summary
-- -----------------------------------------------------
-- RÔLE MÉTIER : Panier utilisateur avec validation stock et calculs temps réel
-- ENDPOINTS LIÉS :
--   • GET /api/v1/cart (affichage panier utilisateur)
--   • PUT /api/v1/cart/items/:id (mise à jour quantité)
--   • POST /api/v1/checkout/validate (validation avant commande)
--   • GET /api/v1/admin/abandoned-carts (analyse paniers abandonnés)
-- JUSTIFICATION : Join cart_items + products pour éviter N+1 queries
-- Calcule automatiquement totaux et valide stock disponible en temps réel
CREATE
OR REPLACE VIEW cart_items_summary AS
SELECT
    -- === PANIER ===
    ci.id AS cart_item_id,
    ci.user_id,
    ci.product_id,
    ci.quantity AS requested_quantity,
    ci.updated_at AS last_modified,
    -- === PRODUIT (données actuelles) ===
    p.name AS product_name,
    p.slug AS product_slug,
    p.sku AS product_sku,
    p.author,
    p.isbn,
    p.price_cents AS current_price_cents, -- Prix actuel (peut avoir changé)
    p.stock_quantity AS available_stock,
    p.is_active AS product_active,
    p.short_description,
    -- === CALCULS AUTOMATIQUES ===
    (ci.quantity * p.price_cents) AS line_total_cents, -- Total ligne
    -- === VALIDATION STOCK ===
    CASE
        WHEN p.stock_quantity >= ci.quantity THEN true
        ELSE false
    END AS stock_sufficient,
    CASE
        WHEN p.stock_quantity > ci.quantity THEN (p.stock_quantity - ci.quantity)
        ELSE 0
    END AS remaining_stock_after, -- Stock restant après cet item
    -- === ALERTES MÉTIER ===
    CASE
        WHEN NOT p.is_active THEN 'PRODUIT_INACTIVE'
        WHEN p.stock_quantity = 0 THEN 'RUPTURE_STOCK'
        WHEN p.stock_quantity < ci.quantity THEN 'STOCK_INSUFFISANT'
        WHEN p.stock_quantity <= p.low_stock_threshold THEN 'STOCK_BAS'
        ELSE 'OK'
    END AS status_alert,
    -- === DONNÉES AFFICHAGE ===
    p.low_stock_threshold,
    -- === AUDIT ===
    ci.added_at AS added_to_cart_at
FROM
    cart_items ci
    JOIN products p ON ci.product_id = p.id -- JOIN obligatoire car besoin données produit actuelles
ORDER BY
    ci.user_id, -- Groupement par utilisateur
    ci.updated_at DESC;

-- Items modifiés récemment d'abord
-- EXPLICATION TECHNIQUE :
-- JOIN products obligatoire car données produit peuvent changer (prix, stock)
-- Calculs pré-faits pour éviter logique complexe côté Node.js
-- Alertes métier exploitables directement par React
-- Garde données même si produit désactivé (pour UX - "ce produit n'est plus disponible")
-- Ordre par updated_at pour montrer dernières modifications (UX)
-- =====================================================
-- RÉSUMÉ ARCHITECTURE - 8 VUES OPTIMISÉES
-- =====================================================
--
-- WORKFLOW E-COMMERCE COUVERT :
-- ┌─────────────────────────┬──────────────────────────┬─────────────────┐
-- │ VUE                     │ PHASE WORKFLOW           │ ENDPOINTS       │
-- ├─────────────────────────┼──────────────────────────┼─────────────────┤
-- │ user_profiles_complete  │ Authentification         │ /auth /profile  │
-- │ user_addresses          │ Profil + Livraisons      │ /addresses      │
-- │ products_catalog        │ Navigation catalogue     │ /products       │
-- │ product_images_list     │ Affichage produits       │ /products/imgs  │
-- │ product_categories_list │ Navigation catégories    │ /categories     │
-- │ cart_items_summary      │ 🆕 PANIER ACTIF         │ /cart           │
-- │ orders_summary          │ Commandes finalisées     │ /orders         │
-- │ order_items_detailed    │ Détail commandes         │ /orders/:id     │
-- └─────────────────────────┴──────────────────────────┴─────────────────┘
--
-- BÉNÉFICES :
-- ✅ API peut choisir les données nécessaires (pas de over-fetching)
-- ✅ Cache facilité (données plates)
-- ✅ Performance (JOINs pré-calculés où nécessaire)
-- ✅ Flexibilité (combinaisons possibles côté Node.js)
