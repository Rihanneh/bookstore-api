-- =====================================================
-- JEU DE DONNÉES TEST E-COMMERCE CULINAIRE - BASÉ SUR DONNÉES JSON (products.json)
-- =====================================================
-- =====================================================
-- JEU DE DONNÉES : TABLE USERS
-- =====================================================
INSERT INTO
    users (
        username,
        email,
        password_hash,
        role_id,
        is_active,
        is_connected,
        email_verified,
        gdpr_consent,
        gdpr_consent_date,
        created_at,
        last_login_at
    )
VALUES
    -- ADMIN SYSTÈME
    (
        'admin_system',
        'admin@cuisinedumonde.fr',
        '$2b$12$KvK8QNWnO5kR7iV.encrypted_admin_password_hash',
        2, -- role_id = 2 (admin)
        true,
        false,
        true,
        true,
        '2024-12-20 10:00:00',
        '2024-12-20 10:00:00',
        '2024-12-22 08:30:00'
    ),
    -- CLIENTS ACTIFS
    (
        'jean_dupont',
        'jean.dupont@email.fr',
        '$2b$12$LwL9QOXoP6lS8jW.encrypted_customer_password_hash',
        1, -- role_id = 1 (customer)
        true,
        false,
        true,
        true,
        '2024-12-15 14:30:00',
        '2024-12-15 14:30:00',
        '2024-12-22 19:45:00'
    ),
    (
        'marie_martin',
        'marie.martin@email.fr',
        '$2b$12$MxM0QPYpQ7mT9kX.encrypted_customer_password_hash',
        1, -- role_id = 1 (customer)
        true,
        true, -- Connectée actuellement
        true,
        true,
        '2024-12-10 09:15:00',
        '2024-12-10 09:15:00',
        '2024-12-22 16:20:00'
    ),
    (
        'pierre_durand',
        'pierre.durand@email.fr',
        '$2b$12$NyN1QRZqR8nU0lY.encrypted_customer_password_hash',
        1, -- role_id = 1 (customer)
        true,
        false,
        true,
        true,
        '2024-12-18 16:45:00',
        '2024-12-18 16:45:00',
        '2024-12-21 20:10:00'
    ),
    (
        'sophie_bernard',
        'sophie.bernard@email.fr',
        '$2b$12$OzO2RSarS9oV1mZ.encrypted_customer_password_hash',
        1, -- role_id = 1 (customer)
        true,
        false,
        false, -- Email pas encore vérifié
        true,
        '2024-12-22 11:00:00',
        '2024-12-22 11:00:00',
        NULL -- Jamais connecté depuis création
    );

-- =====================================================
-- JEU DE DONNÉES : TABLE USER_SESSIONS
-- =====================================================
INSERT INTO
    user_sessions (
        user_id,
        refresh_token,
        device_type,
        expires_at,
        is_active,
        created_at
    )
VALUES
    -- ADMIN SYSTÈME - Session web active (connecté ce matin)
    (
        1, -- admin_system
        'rt_admin_web_2025072808300000_a1b2c3d4e5f6g7h8i9j0k1l2',
        'web',
        '2025-08-04 08:30:00', -- Expire dans 7 jours
        true,
        '2025-07-28 08:30:00'
    ),
    -- MARIE MARTIN - Session web active (connectée cet après-midi)
    (
        3, -- marie_martin
        'rt_marie_web_2025072816200000_m3n4o5p6q7r8s9t0u1v2w3x4',
        'web',
        '2025-08-04 16:20:00', -- Expire dans 7 jours
        true,
        '2025-07-28 16:20:00'
    ),
    -- MARIE MARTIN - Session mobile active (connectée hier)
    (
        3, -- marie_martin
        'rt_marie_mobile_2025072712000000_y5z6a7b8c9d0e1f2g3h4',
        'mobile',
        '2025-08-03 12:00:00', -- Expire dans 6 jours
        true,
        '2025-07-27 12:00:00'
    ),
    -- JEAN DUPONT - Session web récente mais révoquée
    (
        2, -- jean_dupont
        'rt_jean_web_2025072619450000_i5j6k7l8m9n0o1p2q3r4s5t6',
        'web',
        '2025-08-02 19:45:00', -- Expire dans 5 jours
        false, -- Révoqué à la déconnexion
        '2025-07-26 19:45:00'
    ),
    -- PIERRE DURAND - Session desktop active (connecté avant-hier)
    (
        4, -- pierre_durand
        'rt_pierre_desktop_2025072620100000_u7v8w9x0y1z2a3b4c5',
        'desktop',
        '2025-08-02 20:10:00', -- Expire dans 5 jours
        true,
        '2025-07-26 20:10:00'
    );

-- =====================================================
-- JEU DE DONNÉES : TABLE USER_PROFILES
-- =====================================================
INSERT INTO
    user_profiles (
        user_id,
        first_name,
        last_name,
        phone,
        birth_date,
        newsletter_consent,
        newsletter_consent_date,
        avatar_url,
        created_at,
        updated_at
    )
VALUES
    -- PROFIL ADMIN SYSTÈME - Données minimales pro
    (
        1, -- admin_system
        'Jean',
        'Administrateur',
        '+33142868392', -- Format international sans espaces
        '1985-03-15', -- 40 ans
        false, -- Admin ne veut pas de newsletter
        NULL, -- Pas de consentement newsletter
        'https://avatar.example.com/admin_jean.jpg',
        '2025-07-28 08:00:00',
        '2025-07-28 08:00:00'
    ),
    -- PROFIL JEAN DUPONT - Client standard avec newsletter
    (
        2, -- jean_dupont
        'Jean',
        'Dupont',
        '0612345678', -- Mobile français sans espaces
        '1990-07-22', -- 35 ans
        true, -- Accepte newsletter
        '2025-07-28 09:15:00', -- Consentement donné à l'inscription
        NULL, -- Pas d'avatar
        '2025-07-28 09:15:00',
        '2025-07-28 09:15:00'
    ),
    -- PROFIL MARIE MARTIN - Cliente active avec profil complet
    (
        3, -- marie_martin
        'Marie',
        'Martin',
        '0798765432', -- Mobile français sans espaces
        '1988-11-03', -- 36 ans
        true, -- Accepte newsletter
        '2025-07-28 11:30:00', -- Consentement donné à l'inscription
        'https://avatar.example.com/marie_m.jpg',
        '2025-07-28 11:30:00',
        '2025-07-28 16:20:00' -- Profil mis à jour cet après-midi
    ),
    -- PROFIL PIERRE DURAND - Client sans newsletter mais téléphone pro
    (
        4, -- pierre_durand
        'Pierre',
        'Durand',
        '+33467891234', -- Fixe professionnel sans espaces
        '1975-02-28', -- 50 ans
        false, -- Refuse newsletter
        NULL, -- Jamais consenti
        NULL, -- Pas d'avatar
        '2025-07-28 14:45:00',
        '2025-07-28 14:45:00'
    ),
    -- PROFIL SOPHIE BERNARD - Profil minimal (jeune utilisatrice)
    (
        5, -- sophie_bernard
        'Sophie',
        'Bernard',
        NULL, -- Pas de téléphone fourni
        '1995-12-10', -- 29 ans
        true, -- Accepte newsletter
        '2025-07-28 18:20:00', -- Consentement récent
        'https://avatar.example.com/sophie_b.png',
        '2025-07-28 18:20:00',
        '2025-07-28 18:20:00'
    );

-- =====================================================
-- JEU DE DONNÉES : TABLE USER_PAYMENT_METHODS
-- =====================================================
INSERT INTO
    user_payment_methods (
        user_id,
        card_token,
        card_last4,
        card_brand,
        card_type,
        cardholder_name,
        expires_month,
        expires_year,
        nickname,
        is_default,
        is_active,
        created_at,
        updated_at
    )
VALUES
    -- MARIE MARTIN - Carte principale (par défaut)
    (
        3, -- marie_martin
        'tok_stripe_1N2M3O4P5Q6R7S8T9U0V1W2X', -- Token Stripe chiffré
        '4242', -- 4 derniers chiffres Visa test
        'visa',
        'card',
        'MARIE MARTIN',
        12, -- Décembre
        2027, -- Expire en 2027 (valide)
        'Ma carte principale',
        true, -- Carte par défaut
        true,
        '2025-07-28 11:35:00',
        '2025-07-28 11:35:00'
    ),
    -- MARIE MARTIN - Carte secondaire (travail)
    (
        3, -- marie_martin
        'tok_stripe_2A3B4C5D6E7F8G9H0I1J2K3L', -- Token différent
        '1234', -- 4 derniers chiffres différents
        'mastercard',
        'card',
        'M MARTIN',
        6, -- Juin
        2026, -- Expire en 2026
        'Carte travail',
        false, -- Pas par défaut
        true,
        '2025-07-28 12:10:00',
        '2025-07-28 12:10:00'
    ),
    -- JEAN DUPONT - Carte unique
    (
        2, -- jean_dupont
        'tok_stripe_3X4Y5Z6A7B8C9D0E1F2G3H4I', -- Token unique
        '5678', -- 4 derniers chiffres
        'visa',
        'card',
        'JEAN DUPONT',
        3, -- Mars
        2028, -- Expire en 2028
        'Ma carte Visa',
        true, -- Sa seule carte = par défaut
        true,
        '2025-07-28 09:20:00',
        '2025-07-28 09:20:00'
    ),
    -- PIERRE DURAND - PayPal (pas de carte physique)
    (
        4, -- pierre_durand
        'tok_paypal_4J5K6L7M8N9O0P1Q2R3S4T5U', -- Token PayPal
        '0000', -- PayPal n'a pas de "derniers 4"
        'unknown', -- Pas de marque carte pour PayPal
        'paypal',
        'Pierre Durand',
        NULL, -- PayPal n'expire pas comme une carte
        NULL,
        'Mon PayPal',
        true, -- Son seul moyen = par défaut
        true,
        '2025-07-28 14:50:00',
        '2025-07-28 14:50:00'
    ),
    -- PIERRE DURAND - Ancienne carte expirée/désactivée
    (
        4, -- pierre_durand
        'tok_stripe_5V6W7X8Y9Z0A1B2C3D4E5F6G', -- Ancien token
        '9876',
        'amex',
        'card',
        'P DURAND',
        1, -- Janvier
        2025, -- Expirée cette année
        'Ancienne Amex',
        false, -- Plus par défaut
        false, -- Désactivée
        '2024-12-18 16:50:00', -- Créée en décembre dernier
        '2025-07-28 14:52:00' -- Désactivée aujourd'hui
    );

-- =====================================================
-- JEU DE DONNÉES : TABLE CATEGORIES
-- Basé sur la structure hiérarchique du products.json
-- =====================================================
INSERT INTO
    categories (
        name,
        slug,
        description,
        parent_id,
        level,
        sort_order,
        meta_title,
        meta_description,
        is_active,
        created_at
    )
VALUES
    -- =====================================================
    -- NIVEAU 0 : CATÉGORIES RACINES
    -- =====================================================
    -- Cuisine du Monde (catégorie principale)
    (
        'Cuisine du Monde',
        'cuisine-du-monde',
        'Découvrez les saveurs authentiques des cuisines du monde entier',
        NULL, -- Racine
        0, -- Niveau 0
        1, -- Premier dans l''ordre
        'Cuisine du Monde - Épices et Condiments Authentiques',
        'Explorez notre sélection d''épices, condiments et spécialités culinaires du monde entier pour vos recettes authentiques.',
        true,
        '2025-07-28 08:00:00'
    ),
    -- Ustensiles (catégorie secondaire)
    (
        'Ustensiles de Cuisine',
        'ustensiles-cuisine',
        'Équipements et accessoires pour cuisiner comme un chef',
        NULL, -- Racine
        0, -- Niveau 0
        2, -- Deuxième dans l''ordre
        'Ustensiles de Cuisine - Équipements Culinaires',
        'Découvrez notre gamme d''ustensiles de cuisine professionnels et accessoires pour réussir toutes vos recettes.',
        true,
        '2025-07-28 08:05:00'
    ),
    -- =====================================================
    -- NIVEAU 1 : RÉGIONS CULINAIRES (sous Cuisine du Monde)
    -- =====================================================
    -- Cuisine Asiatique
    (
        'Cuisine Asiatique',
        'cuisine-asiatique',
        'Épices, sauces et condiments d''Asie : Chine, Japon, Thaïlande, Inde...',
        1, -- parent_id = Cuisine du Monde
        1, -- Niveau 1
        1,
        'Cuisine Asiatique - Épices et Condiments d''Asie',
        'Saveurs authentiques d''Asie : épices indiennes, sauces japonaises, condiments thaïlandais et chinois.',
        true,
        '2025-07-28 08:10:00'
    ),
    -- Cuisine Européenne
    (
        'Cuisine Européenne',
        'cuisine-europeenne',
        'Spécialités culinaires d''Europe : France, Italie, Espagne, Grèce...',
        1, -- parent_id = Cuisine du Monde
        1, -- Niveau 1
        2,
        'Cuisine Européenne - Spécialités Culinaires',
        'Découvrez les trésors gastronomiques européens : herbes de Provence, huiles d''olive, vinaigres balsamiques.',
        true,
        '2025-07-28 08:15:00'
    ),
    -- Cuisine des Amériques
    (
        'Cuisine des Amériques',
        'cuisine-ameriques',
        'Saveurs du Nouveau Monde : Mexique, Pérou, États-Unis, Brésil...',
        1, -- parent_id = Cuisine du Monde
        1, -- Niveau 1
        3,
        'Cuisine des Amériques - Saveurs du Nouveau Monde',
        'Épices mexicaines, condiments péruviens, sauces américaines : explorez les saveurs des Amériques.',
        true,
        '2025-07-28 08:20:00'
    ),
    -- Cuisine du Moyen-Orient et Afrique
    (
        'Moyen-Orient & Afrique',
        'moyen-orient-afrique',
        'Épices et mélanges traditionnels du Moyen-Orient et d''Afrique',
        1, -- parent_id = Cuisine du Monde
        1, -- Niveau 1
        4,
        'Cuisine Moyen-Orient Afrique - Épices Traditionnelles',
        'Ras el hanout, za''atar, épices berbères : découvrez les mélanges authentiques du Moyen-Orient et d''Afrique.',
        true,
        '2025-07-28 08:25:00'
    ),
    -- =====================================================
    -- NIVEAU 2 : SOUS-RÉGIONS SPÉCIFIQUES
    -- =====================================================
    -- Cuisine Indienne (sous Asiatique)
    (
        'Cuisine Indienne',
        'cuisine-indienne',
        'Épices et mélanges traditionnnels de l''Inde : garam masala, curcuma, cardamome...',
        3, -- parent_id = Cuisine Asiatique
        2, -- Niveau 2
        1,
        'Épices Indiennes - Garam Masala, Curcuma, Curry',
        'Authentiques épices indiennes : garam masala, curcuma bio, cardamome, coriandre pour vos curry maison.',
        true,
        '2025-07-28 08:30:00'
    ),
    -- Cuisine Japonaise (sous Asiatique)
    (
        'Cuisine Japonaise',
        'cuisine-japonaise',
        'Condiments japonais : sauce soja, miso, wasabi, vinaigre de riz...',
        3, -- parent_id = Cuisine Asiatique
        2, -- Niveau 2
        2,
        'Condiments Japonais - Sauce Soja, Miso, Wasabi',
        'Condiments japonais authentiques : sauce soja premium, pâte miso, wasabi frais pour cuisine nippone.',
        true,
        '2025-07-28 08:35:00'
    ),
    -- Cuisine Thaïlandaise (sous Asiatique)
    (
        'Cuisine Thaïlandaise',
        'cuisine-thailandaise',
        'Épices et pâtes thaïlandaises : pâte de curry, citronnelle, galanga...',
        3, -- parent_id = Cuisine Asiatique
        2, -- Niveau 2
        3,
        'Épices Thaïlandaises - Pâtes de Curry, Citronnelle',
        'Épices thaï authentiques : pâtes de curry rouge et vert, citronnelle, feuilles de combava.',
        true,
        '2025-07-28 08:40:00'
    ),
    -- Cuisine Française (sous Européenne)
    (
        'Cuisine Française',
        'cuisine-francaise',
        'Herbes et épices de France : herbes de Provence, fleur de sel, moutarde...',
        4, -- parent_id = Cuisine Européenne
        2, -- Niveau 2
        1,
        'Épices Françaises - Herbes de Provence, Fleur de Sel',
        'Saveurs françaises traditionnelles : herbes de Provence, fleur de sel de Guérande, moutarde de Dijon.',
        true,
        '2025-07-28 08:45:00'
    ),
    -- Cuisine Italienne (sous Européenne)
    (
        'Cuisine Italienne',
        'cuisine-italienne',
        'Condiments italiens : huiles d''olive, vinaigres, herbes méditerranéennes...',
        4, -- parent_id = Cuisine Européenne
        2, -- Niveau 2
        2,
        'Condiments Italiens - Huiles d''Olive, Vinaigres',
        'Condiments italiens premium : huiles d''olive extra vierge, vinaigres balsamiques, herbes de Sicile.',
        true,
        '2025-07-28 08:50:00'
    ),
    -- Cuisine Mexicaine (sous Amériques)
    (
        'Cuisine Mexicaine',
        'cuisine-mexicaine',
        'Épices mexicaines : piments, cumin, paprika fumé, mélanges tex-mex...',
        5, -- parent_id = Cuisine des Amériques
        2, -- Niveau 2
        1,
        'Épices Mexicaines - Piments, Cumin, Paprika Fumé',
        'Épices mexicaines authentiques : piments chipotle, cumin grillé, paprika fumé pour tacos et fajitas.',
        true,
        '2025-07-28 08:55:00'
    ),
    -- =====================================================
    -- NIVEAU 1 : TYPES D'USTENSILES (sous Ustensiles)
    -- =====================================================
    -- Cuisson
    (
        'Ustensiles de Cuisson',
        'ustensiles-cuisson',
        'Poêles, casseroles, woks et matériel de cuisson professionnel',
        2, -- parent_id = Ustensiles de Cuisine
        1, -- Niveau 1
        1,
        'Ustensiles de Cuisson - Poêles, Casseroles, Woks',
        'Matériel de cuisson professionnel : poêles anti-adhésives, woks en acier, casseroles en inox.',
        true,
        '2025-07-28 09:00:00'
    ),
    -- Préparation
    (
        'Ustensiles de Préparation',
        'ustensiles-preparation',
        'Couteaux, planches à découper, râpes et accessoires de préparation',
        2, -- parent_id = Ustensiles de Cuisine
        1, -- Niveau 1
        2,
        'Ustensiles de Préparation - Couteaux, Planches',
        'Outils de préparation culinaire : couteaux japonais, planches en bambou, mandolines professionnelles.',
        true,
        '2025-07-28 09:05:00'
    );

-- =====================================================
-- JEU DE DONNÉES : TABLE PRODUCTS
-- Basé sur products.json
-- =====================================================
INSERT INTO
    products (
        name,
        slug,
        sku,
        author,
        isbn,
        page_count,
        publication_year,
        language,
        publisher,
        short_description,
        description,
        price_cents,
        tax_rate_id,
        stock_quantity,
        low_stock_threshold,
        manage_stock,
        meta_title,
        meta_description,
        is_active,
        is_featured,
        created_by,
        created_at,
        updated_at
    )
VALUES
    -- LIVRE 1
    (
        'Les Secrets de la Cuisine Française',
        'les-secrets-de-la-cuisine-francaise', -- Slug valide (a-z0-9-)
        'COOK-FR-001', -- SKU unique
        'Marie Dubois',
        '978-2-123456-78-9', -- ISBN-13 format valide
        320, -- > 0
        2023, -- Entre 1900 et 2026
        'fr', -- Langue valide
        'Éditions Culinaires',
        'Guide traditionnel de la gastronomie française avec 200+ recettes authentiques.',
        'Découvrez les techniques traditionnelles et les recettes authentiques de la gastronomie française. Un voyage culinaire à travers les régions de France avec plus de 200 recettes détaillées.',
        2990, -- 29.90€ = 2990 centimes
        3, -- TVA Super Réduite 5.5%
        15, -- >= 0
        5, -- Seuil bas stock
        TRUE,
        'Les Secrets de la Cuisine Française - Livre de recettes traditionnelles',
        'Découvrez la gastronomie française authentique avec ce guide complet de 320 pages par Marie Dubois.',
        TRUE,
        FALSE,
        1, -- admin_system
        '2024-12-15 10:00:00',
        '2024-12-15 10:00:00'
    ),
    -- LIVRE 2
    (
        'Cuisine Italienne Moderne',
        'cuisine-italienne-moderne',
        'COOK-IT-002',
        'Giovanni Rossi',
        '978-2-987654-32-1',
        280,
        2023,
        'fr',
        'Bella Vista Publishing',
        'Cuisine italienne contemporaine par un chef étoilé, tradition et innovation.',
        'Une approche contemporaine de la cuisine italienne, alliant tradition et innovation. Des recettes revisitées par un chef étoilé pour sublimer les saveurs méditerranéennes.',
        3495, -- 34.95€ = 3495 centimes
        3,
        8,
        3,
        TRUE,
        'Cuisine Italienne Moderne - Recettes contemporaines par Giovanni Rossi',
        'Cuisine italienne revisitée par un chef étoilé. 280 pages de recettes modernes et traditionnelles.',
        TRUE,
        TRUE, -- Produit mis en avant
        1,
        '2024-12-15 10:30:00',
        '2024-12-15 10:30:00'
    ),
    -- LIVRE 3
    (
        'Pâtisserie Artisanale',
        'patisserie-artisanale',
        'COOK-PA-003',
        'Sophie Laurent',
        '978-3-456789-01-2',
        450,
        2024,
        'fr',
        'Sucré Salé Éditions',
        'Guide complet de la pâtisserie française, techniques et créations modernes.',
        'Maîtrisez l''art de la pâtisserie française avec ce guide complet. Techniques de base, recettes classiques et créations modernes expliquées pas à pas.',
        4250, -- 42.50€ = 4250 centimes
        3,
        12,
        5,
        TRUE,
        'Pâtisserie Artisanale - Guide complet par Sophie Laurent',
        'Apprenez la pâtisserie française avec 450 pages de techniques et recettes par Sophie Laurent.',
        TRUE,
        TRUE, -- Produit mis en avant
        1,
        '2024-12-15 11:00:00',
        '2024-12-15 11:00:00'
    ),
    -- LIVRE 4
    (
        'Cuisine Asiatique Fusion',
        'cuisine-asiatique-fusion',
        'COOK-AS-004',
        'Kenji Tanaka',
        '978-4-567890-12-3',
        350,
        2023,
        'fr',
        'Orient Express Books',
        'Saveurs d''Asie moderne, fusion des traditions culinaires asiatiques et occidentales.',
        'Explorez les saveurs d''Asie avec une touche moderne. Recettes fusion qui marient les traditions culinaires asiatiques avec des techniques occidentales contemporaines.',
        3120, -- 31.20€ = 3120 centimes
        3,
        20,
        8,
        TRUE,
        'Cuisine Asiatique Fusion - Recettes modernes par Kenji Tanaka',
        'Cuisine asiatique fusion par Kenji Tanaka. 350 pages de recettes modernes mêlant Orient et Occident.',
        TRUE,
        FALSE,
        1,
        '2024-12-15 11:30:00',
        '2024-12-15 11:30:00'
    ),
    -- LIVRE 5
    (
        'Barbecue et Grillades',
        'barbecue-et-grillades',
        'COOK-BB-005',
        'Jack Thompson',
        '978-5-678901-23-4',
        240,
        2024,
        'fr',
        'Grill Master Publishing',
        'Guide ultime du barbecue, techniques de cuisson et marinades pour maître du grill.',
        'Le guide ultime du barbecue et des grillades. Techniques de cuisson, marinades, accompagnements et recettes pour devenir un maître du grill.',
        2580, -- 25.80€ = 2580 centimes
        3,
        18,
        7,
        TRUE,
        'Barbecue et Grillades - Guide du maître grill par Jack Thompson',
        'Devenez maître du barbecue avec ce guide de 240 pages par Jack Thompson. Techniques et recettes.',
        TRUE,
        FALSE,
        1,
        '2024-12-15 12:00:00',
        '2024-12-15 12:00:00'
    );

-- =====================================================
-- PRODUCT_CATEGORIES - BASÉ SUR NOS 5 LIVRES RÉELS
-- =====================================================
INSERT INTO
    product_categories (
        product_id,
        category_id,
        is_primary,
        sort_order,
        created_at
    )
VALUES
    -- LIVRE 1: Les Secrets de la Cuisine Française
    (1, 10, true, 1, '2024-12-15 10:00:00'), -- Cuisine Française (PRIMARY)
    (1, 4, false, 2, '2024-12-15 10:00:00'), -- Cuisine Européenne
    (1, 1, false, 3, '2024-12-15 10:00:00'), -- Cuisine du Monde
    -- LIVRE 2: Cuisine Italienne Moderne
    (2, 11, true, 1, '2024-12-15 10:30:00'), -- Cuisine Italienne (PRIMARY)
    (2, 4, false, 2, '2024-12-15 10:30:00'), -- Cuisine Européenne
    (2, 1, false, 3, '2024-12-15 10:30:00'), -- Cuisine du Monde
    -- LIVRE 3: Pâtisserie Artisanale
    (3, 10, true, 1, '2024-12-15 11:00:00'), -- Cuisine Française (PRIMARY - pâtisserie française)
    (3, 4, false, 2, '2024-12-15 11:00:00'), -- Cuisine Européenne
    (3, 1, false, 3, '2024-12-15 11:00:00'), -- Cuisine du Monde
    -- LIVRE 4: Cuisine Asiatique Fusion
    (4, 3, true, 1, '2024-12-15 11:30:00'), -- Cuisine Asiatique (PRIMARY)
    (4, 1, false, 2, '2024-12-15 11:30:00'), -- Cuisine du Monde
    -- LIVRE 5: Barbecue et Grillades
    (5, 1, true, 1, '2024-12-15 12:00:00');

-- Cuisine du Monde (PRIMARY - techniques universelles)
-- =====================================================
-- JEU DE DONNÉES : TABLE PRODUCT_REVIEWS
-- Avis clients réalistes pour nos 5 livres de cuisine
-- =====================================================
INSERT INTO
    product_reviews (
        product_id,
        user_id,
        anonymous_name,
        rating,
        title,
        comment,
        is_verified_purchase,
        is_moderated,
        is_published,
        is_anonymous,
        created_at,
        updated_at,
        anonymized_at
    )
VALUES
    -- =====================================================
    -- LIVRE 1 : Les Secrets de la Cuisine Française
    -- =====================================================
    -- Avis utilisateur connecté - très positif
    (
        1,
        2,
        NULL,
        5,
        'Un livre exceptionnel !',
        'Ce livre est une véritable bible de la cuisine française. Les explications sont claires, les recettes authentiques et les photos magnifiques. J''ai déjà testé 5 recettes et c''est un régal à chaque fois !',
        TRUE,
        TRUE,
        TRUE,
        FALSE,
        '2024-12-16 14:30:00',
        '2024-12-16 14:30:00',
        NULL
    ),
    -- Avis utilisateur anonymisé - positif
    (
        1,
        NULL,
        'Claire M.',
        4,
        'Très bon guide culinaire',
        'Les techniques sont bien expliquées. Parfait pour débuter dans la cuisine traditionnelle française. Quelques recettes un peu complexes pour les débutants mais globalement excellent.',
        TRUE,
        TRUE,
        TRUE,
        TRUE,
        '2024-12-17 09:15:00',
        '2024-12-17 09:15:00',
        '2024-12-20 10:00:00'
    ),
    -- Avis récent utilisateur connecté - très positif
    (
        1,
        3,
        NULL,
        5,
        'Références gastronomiques parfaites',
        'Marie Dubois maîtrise son sujet. Les 200+ recettes sont un trésor. Mon livre de chevet maintenant !',
        TRUE,
        FALSE,
        TRUE,
        FALSE,
        '2024-12-20 16:45:00',
        '2024-12-20 16:45:00',
        NULL
    ),
    -- =====================================================
    -- LIVRE 2 : Cuisine Italienne Moderne
    -- =====================================================
    -- Avis mitigé - utilisateur connecté
    (
        2,
        4,
        NULL,
        3,
        'Moyennement convaincu',
        'Les recettes sont intéressantes mais certaines manquent de précision dans les quantités. Les photos sont belles mais j''attendais plus de modernité dans les approches.',
        FALSE,
        TRUE,
        TRUE,
        FALSE,
        '2024-12-18 11:20:00',
        '2024-12-18 11:20:00',
        NULL
    ),
    -- Avis très positif - utilisateur anonymisé
    (
        2,
        NULL,
        'Marco R.',
        5,
        'Bellissimo !',
        'En tant qu''Italien, je valide complètement ! Giovanni Rossi a su moderniser nos classiques sans les dénaturer. Bravo !',
        TRUE,
        TRUE,
        TRUE,
        TRUE,
        '2024-12-19 19:30:00',
        '2024-12-19 19:30:00',
        '2024-12-22 8:00:00'
    ),
    -- =====================================================
    -- LIVRE 3 : Pâtisserie Artisanale
    -- =====================================================
    -- Avis enthousiaste - produit mis en avant
    (
        3,
        2,
        NULL,
        5,
        'LA référence en pâtisserie !',
        'Sophie Laurent est une magicienne ! Ses explications sont d''une précision chirurgicale. Mes premiers macarons ont été parfaits du premier coup grâce à ses conseils. 450 pages de pur bonheur !',
        TRUE,
        TRUE,
        TRUE,
        FALSE,
        '2024-12-19 15:10:00',
        '2024-12-19 15:10:00',
        NULL
    ),
    -- Avis débutant satisfait
    (
        3,
        5,
        NULL,
        4,
        'Accessible même aux débutants',
        'J''avais peur que ce soit trop technique mais les bases sont très bien expliquées. J''ai réussi mes premiers éclairs ! Manque juste quelques vidéos en complément.',
        TRUE,
        FALSE,
        TRUE,
        FALSE,
        '2024-12-21 10:25:00',
        '2024-12-21 10:25:00',
        NULL
    ),
    -- =====================================================
    -- LIVRE 4 : Cuisine Asiatique Fusion
    -- =====================================================
    -- Avis original et positif
    (
        4,
        3,
        NULL,
        4,
        'Fusion réussie !',
        'Kenji Tanaka réussit parfaitement le mélange Orient-Occident. Les saveurs sont authentiques tout en restant accessibles. Mon ramen-burger maison a fait sensation !',
        TRUE,
        TRUE,
        TRUE,
        FALSE,
        '2024-12-20 13:40:00',
        '2024-12-20 13:40:00',
        NULL
    ),
    -- Avis anonyme critique constructive
    (
        4,
        NULL,
        'SushiLover99',
        3,
        'Bon mais pas révolutionnaire',
        'Les recettes sont correctes mais j''espérais plus d''innovation. Certaines associations sont un peu forcées. Reste un bon livre pour découvrir la fusion asiatique.',
        FALSE,
        TRUE,
        TRUE,
        TRUE,
        '2024-12-21 20:15:00',
        '2024-12-21 20:15:00',
        '2024-12-23 14:30:00'
    ),
    -- =====================================================
    -- LIVRE 5 : Barbecue et Grillades
    -- =====================================================
    -- Avis passionné utilisateur connecté
    (
        5,
        4,
        NULL,
        5,
        'Le guide ultime du BBQ !',
        'Jack Thompson connaît son affaire ! Ses techniques de marinade ont révolutionné mes barbecues. Mes invités me demandent maintenant mes secrets. Merci pour ce guide complet !',
        TRUE,
        TRUE,
        TRUE,
        FALSE,
        '2024-12-22 12:00:00',
        '2024-12-22 12:00:00',
        NULL
    ),
    -- Avis saisonnier positif
    (
        5,
        5,
        NULL,
        4,
        'Parfait pour l''été prochain',
        'Acheté en prévision de la saison BBQ. Les 240 pages regorgent de conseils pratiques. Hâte de tester les recettes fumage !',
        TRUE,
        FALSE,
        TRUE,
        FALSE,
        '2024-12-23 16:25:00',
        '2024-12-23 16:25:00',
        NULL
    ),
    -- Avis technique anonymisé
    (
        5,
        NULL,
        'GrillMaster',
        5,
        'Techniques de pro !',
        'Enfin un guide qui va au-delà des basiques ! Les techniques de fumage à froid et les marinades 24h changent tout. Indispensable pour tout amateur de grillades.',
        TRUE,
        TRUE,
        TRUE,
        TRUE,
        '2024-12-24 11:45:00',
        '2024-12-24 11:45:00',
        '2024-12-26 9:20:00'
    );

-- =====================================================
-- JEU DE DONNÉES : TABLE PRODUCT_IMAGES
-- Basé sur le products.json réel
-- =====================================================
INSERT INTO
    product_images (
        product_id,
        image_url,
        alt_text,
        is_primary,
        sort_order,
        uploaded_by,
        uploaded_at
    )
VALUES
    -- =====================================================
    -- LIVRE 1 : Les Secrets de la Cuisine Française (Marie Dubois)
    -- ID: 1, ISBN: 978-2-123456-78-9
    -- =====================================================
    (
        1,
        'https://images.example.com/les-secrets-cuisine-francaise-cover.jpg',
        'Couverture du livre ''Les Secrets de la Cuisine Française'' par Marie Dubois.',
        TRUE,
        0,
        1,
        '2024-11-15 09:00:00'
    ),
    (
        1,
        'https://images.example.com/les-secrets-cuisine-francaise-pages.jpg',
        'Aperçu des 320 pages avec plus de 200 recettes françaises traditionnelles.',
        FALSE,
        1,
        1,
        '2024-11-15 09:15:00'
    ),
    -- =====================================================
    -- LIVRE 2 : Cuisine Italienne Moderne (Giovanni Rossi)
    -- ID: 2, ISBN: 978-88-123456-78-9
    -- =====================================================
    (
        2,
        'https://images.example.com/cuisine-italienne-moderne-cover.jpg',
        'Couverture du livre ''Cuisine Italienne Moderne'' par Giovanni Rossi.',
        TRUE,
        0,
        1,
        '2024-11-16 10:30:00'
    ),
    (
        2,
        'https://images.example.com/cuisine-italienne-moderne-recettes.jpg',
        'Recettes italiennes revisitées, 280 pages de saveurs modernes.',
        FALSE,
        1,
        1,
        '2024-11-16 10:45:00'
    ),
    -- =====================================================
    -- LIVRE 3 : Pâtisserie Artisanale (Sophie Laurent)
    -- ID: 3, ISBN: 978-2-987654-32-1
    -- =====================================================
    (
        3,
        'https://images.example.com/patisserie-artisanale-cover.jpg',
        'Couverture du livre ''Pâtisserie Artisanale'' par Sophie Laurent.',
        TRUE,
        0,
        1,
        '2024-11-17 14:00:00'
    ),
    (
        3,
        'https://images.example.com/patisserie-artisanale-techniques.jpg',
        'Techniques de pâtisserie professionnelle présentées en 350 pages.',
        FALSE,
        1,
        1,
        '2024-11-17 14:20:00'
    ),
    (
        3,
        'https://images.example.com/patisserie-artisanale-desserts.jpg',
        'Créations pâtissières illustrées dans le livre ''Pâtisserie Artisanale''.',
        FALSE,
        2,
        1,
        '2024-11-17 14:40:00'
    ),
    -- =====================================================
    -- LIVRE 4 : Cuisine Asiatique Fusion (Kenji Tanaka)
    -- ID: 4, ISBN: 978-4-123456-78-9
    -- =====================================================
    (
        4,
        'https://images.example.com/cuisine-asiatique-fusion-cover.jpg',
        'Couverture du livre ''Cuisine Asiatique Fusion'' par Kenji Tanaka.',
        TRUE,
        0,
        1,
        '2024-11-18 11:30:00'
    ),
    (
        4,
        'https://images.example.com/cuisine-asiatique-fusion-plats.jpg',
        'Plats de fusion asiatique-occidentale : 300 pages d''innovation.',
        FALSE,
        1,
        1,
        '2024-11-18 11:50:00'
    ),
    -- =====================================================
    -- LIVRE 5 : Barbecue et Grillades (Jack Thompson)
    -- ID: 5, ISBN: 978-1-234567-89-0
    -- =====================================================
    (
        5,
        'https://images.example.com/barbecue-grillades-cover.jpg',
        'Couverture du livre ''Barbecue et Grillades'' de Jack Thompson.',
        TRUE,
        0,
        1,
        '2024-11-19 16:00:00'
    ),
    (
        5,
        'https://images.example.com/barbecue-grillades-techniques.jpg',
        'Techniques de barbecue et grillades présentées en 240 pages.',
        FALSE,
        1,
        1,
        '2024-11-19 16:20:00'
    );

-- =====================================================
-- JEU DE DONNÉES : TABLE ADDRESSES
--
-- =====================================================
INSERT INTO
    addresses (
        user_id,
        type,
        first_name,
        last_name,
        company,
        phone,
        address_line_1,
        address_line_2,
        city,
        postal_code,
        state_region,
        country,
        is_default
    )
VALUES
    (
        1,
        'shipping',
        'Marie',
        'Dubois',
        NULL,
        '+33123456789',
        '15 Rue de la Paix',
        NULL,
        'Paris',
        '75002',
        'Île-de-France',
        'FR',
        TRUE
    ),
    (
        1,
        'billing',
        'Marie',
        'Dubois',
        'Les Éditions du Terroir',
        '+33198765432',
        '25 Avenue des Champs-Élysées',
        'Bureau 10',
        'Paris',
        '75008',
        'Île-de-France',
        'FR',
        FALSE
    ),
    (
        2,
        'both',
        'Jean',
        'Martin',
        NULL,
        '+33412345678',
        '45 Boulevard de la République',
        'Apt 202',
        'Lyon',
        '69001',
        'Auvergne-Rhône-Alpes',
        'FR',
        FALSE
    ),
    (
        3,
        'shipping',
        'Laura',
        'Bernard',
        NULL,
        '+33523456789',
        '78 Rue de la Liberté',
        'Résidence Fleurie',
        'Marseille',
        '13001',
        'Provence-Alpes-Côte d''Azur',
        'FR',
        TRUE
    ),
    (
        3,
        'billing',
        'Laura',
        'Bernard',
        'Société Innovative',
        '+33634567890',
        '12 Rue des Lilas',
        NULL,
        'Marseille',
        '13002',
        'Provence-Alpes-Côte d''Azur',
        'FR',
        FALSE
    );

-- =====================================================
-- JEU DE DONNÉES : TABLE ORDERS
-- Basé sur le products.json réel
-- =====================================================
INSERT INTO
    cart_items (user_id, product_id, quantity)
VALUES
    (1, 1, 2), -- Utilisateur 1, Produit 1, Quantité 2
    (1, 3, 1), -- Utilisateur 1, Produit 3, Quantité 1
    (2, 2, 3), -- Utilisateur 2, Produit 2, Quantité 3
    (3, 5, 1), -- Utilisateur 3, Produit 5, Quantité 1
    (1, 4, 5);

-- Utilisateur 1, Produit 4, Quantité 5
-- =====================================================
-- JEU DE DONNÉES : TABLE ORDERS
--
-- =====================================================
INSERT INTO
    orders (
        order_number,
        user_id,
        shipping_address_id,
        billing_address_id,
        status,
        subtotal_cents,
        tax_amount_cents,
        shipping_cents,
        total_cents,
        payment_status,
        payment_method,
        payment_reference,
        shipping_method,
        tracking_number,
        customer_notes,
        admin_notes,
        shipped_at,
        delivered_at
    )
VALUES
    (
        'ORD-20250127-001',
        1,
        1,
        1,
        'pending',
        5980,
        500,
        1000,
        7480,
        'pending',
        'stripe',
        'pi_12345',
        'Standard',
        NULL,
        'Livraison express',
        'Préparer pour expédition.',
        NULL,
        NULL
    ),
    (
        'ORD-20250127-002',
        2,
        2,
        2,
        'processing',
        10485,
        0,
        0,
        10485,
        'paid',
        'paypal',
        'pi_67890',
        'Expedited',
        'TRACK123',
        'Ajouter une note',
        'Commander des étiquettes.',
        NULL,
        NULL
    ),
    (
        'ORD-20250127-003',
        3,
        3,
        3,
        'shipped',
        4250,
        600,
        2000,
        6850,
        'paid',
        'stripe',
        'pi_11223',
        'Standard',
        'TRACK456',
        'Vérifier le statut',
        'Préparer le colis.',
        NOW (),
        NULL
    ),
    (
        'ORD-20250127-004',
        1,
        1,
        1,
        'delivered',
        15600,
        1200,
        3000,
        19800,
        'refunded',
        'paypal',
        'pi_44556',
        'Express',
        'TRACK789',
        'Satisfaction garantie',
        'Processus de retour.',
        NOW (),
        NOW ()
    ),
    (
        'ORD-20250127-005',
        2,
        2,
        2,
        'cancelled',
        6990,
        400,
        1000,
        8390,
        'failed',
        'stripe',
        'pi_78901',
        'Standard',
        NULL,
        'Annulation de commande.',
        'Remboursement à traiter.',
        NULL,
        NULL
    );

INSERT INTO order_items (
    order_id,
    product_id,
    product_name,
    product_sku,
    unit_price_cents,
    tax_rate,
    quantity,
    line_subtotal_cents,
    line_tax_cents,
    line_total_cents
) VALUES
    -- Pour la commande 1
    (
        1,  -- order_id
        1,  -- product_id
        'Les Secrets de la Cuisine Française',
        'COOK-FR-001',
        2990,      -- prix unitaire
        0.20,      -- taux de TVA (20%)
        2,         -- quantité
        5980,      -- sous-total (2990 * 2)
        1196,      -- TVA (5980 * 0.20)
        7176       -- total (5980 + 1196)
    ),
    -- Pour la commande 2
    (
        2,  -- order_id
        2,  -- product_id
        'Cuisine Italienne Moderne',
        'COOK-IT-002',
        3495,      -- prix unitaire
        0.20,      -- taux de TVA (20%)
        1,         -- quantité
        3495,      -- sous-total
        699,       -- TVA (3495 * 0.20)
        4194       -- total (3495 + 699)
    ),
    -- Pour la commande 3
    (
        3,  -- order_id
        3,  -- product_id
        'Pâtisserie Artisanale',
        'COOK-PA-003',
        4250,      -- prix unitaire
        0.20,      -- taux de TVA (20%)
        1,         -- quantité
        4250,      -- sous-total
        850,       -- TVA (4250 * 0.20)
        5100       -- total (4250 + 850)
    ),
    -- Pour la commande 4
    (
        4,  -- order_id
        4,  -- product_id
        'Cuisine Asiatique Fusion',
        'COOK-AS-004',
        3120,      -- prix unitaire
        0.20,      -- taux de TVA (20%)
        3,         -- quantité
        9360,      -- sous-total (3120 * 3)
        1872,      -- TVA (9360 * 0.20)
        11232      -- total (9360 + 1872)
    ),
    -- Pour la commande 5
    (
        5,  -- order_id
        1,  -- product_id (par exemple)
        'Les Secrets de la Cuisine Française',
        'COOK-FR-001',
        2990,      -- prix unitaire
        0.20,      -- taux de TVA (20%)
        2,         -- quantité
        5980,      -- sous-total
        1196,      -- TVA (5980 * 0.20)
        7176       -- total (5980 + 1196)
    );

