# bookstore-api
```
bookstore-api
├─ .editorconfig
├─ .prettierignore
├─ LICENSE
├─ README.md
├─ docs
│  ├─ README.md
│  ├─ diagrams
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
│  │  ├─ plantuml-documentation.md
│  │  └─ singletons
│  │     ├─ 01-diagram-class-loggerSingleton.png
│  │     ├─ 01-diagram-class-loggerSingleton.wsd
│  │     ├─ 02-diagram-sequence-loggerSingleton-test.png
│  │     └─ 02-diagram-sequence-loggerSingleton-test.wsd
│  └─ security
│     ├─ 01-security-passwordHasher-and-tokenManagement.png
│     └─ 01-security-passwordHasher-and-tokenManagement.wsd
├─ eslint.config.js
├─ jest.config.js
├─ package-lock.json
├─ package.json
├─ prettier.config.js
├─ src
│  ├─ app.ts
│  ├─ entities
│  │  ├─ BaseEntity.ts
│  │  ├─ Role.ts
│  │  └─ User.ts
│  ├─ enums
│  │  └─ RoleEnum.ts
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
│  ├─ server.ts
│  ├─ singletons
│  │  ├─ LoggerSingleton.ts
│  │  └─ __tests__
│  │     └─ LoggerSingleton.test.ts
│  └─ utils
│     ├─ PasswordHasher.ts
│     └─ __tests__
│        └─ PasswordHasher.test.ts
├─ srcserver.ts
└─ tsconfig.json

```