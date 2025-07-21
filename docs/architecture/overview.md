# Architecture MVC avec couche service, repository, dtos

```
bookstore-api
├─ LICENSE
├─ README.md
├─ .editorconfig
├─ .prettierignore
├─ eslint.config.js
├─ prettier.config.js
├─ src
│  ├─ server.ts
│  ├─ app.ts
│  ├─ exceptions
│  │  ├─ ApiError.ts
│  │  ├─ __tests__
│  │  │  └─ ApiError.test.ts
│  │  └─ security
│  │     └─ PasswordError.ts
│  ├─ interfaces
│  │  ├─ entities
│  │  │  ├─ IBaseEntityData.ts
│  │  │  ├─ IEntity.ts
│  │  │  └─ user
│  │  │     ├─ IRoleData.ts
│  │  │     └─ IUserData.ts
│  │  └─ security
│  │     ├─ IAdditionalInfo.ts
│  │     └─ IPasswordHasher.ts
│  ├─ singletons
│  │  ├─ LoggerSingleton.ts
│  │  └─ __tests__
│  │     └─ LoggerSingleton.test.ts
│  ├─ entities
│  │  ├─ BaseEntity.ts
│  │  ├─ Role.ts
│  │  └─ User.ts
│  ├─ enums
│  │  └─ RoleEnum.ts
│  └─ utils
│     ├─ __tests__
│     │  └─ PasswordHasher.test.ts
│     └─ PassswordHasher.ts
├─ jest.config.js
├─ package-lock.json
├─ docs
│  ├─ diagrams
│  │  ├─ singletons
│  │  │  ├─ 01-diagram-class-loggerSingleton.png
│  │  │  ├─ 01-diagram-class-loggerSingleton.wsd
│  │  │  ├─ 02-diagram-sequence-loggerSingleton-test.png
│  │  │  └─ 02-diagram-sequence-loggerSingleton-test.wsd
│  │  ├─ entities
│  │  │  └─ user
│  │  │     ├─ 01-class-diagram-entities-mvp-base.png
│  │  │     └─ 01-class-diagram-entities-mvp-base.wsd
│  │  ├─ exceptions
│  │  │  ├─ 01-class-diagram-api-error-singleton.png
│  │  │  └─ 01-class-diagram-api-error-singleton.wsd
│  │  ├─ img
│  │  │  ├─ 01-diagramme-entités-métier-et-architecture-technique.png
│  │  │  └─ 01-diagramme-entités-métier-et-architecture-technique.wsd
│  │  └─ plantuml-documentation.md
│  ├─ security
│  │  ├─ 01-security-passwordHasher-and-tokenManagement.wsd
│  │  └─ 01-security-passwordHasher-and-tokenManagement.png
│  └─ README.md
├─ package.json
└─ tsconfig.json

```
