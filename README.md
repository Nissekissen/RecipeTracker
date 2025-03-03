# ReceptBasen eller RecipeTracker (har inte bestämt mig än)

[Länk till drawsql](https://drawsql.app/teams/nils-lindblads-team/diagrams/recept-basen)

## TODO:

- [ ] Recept
  - [x] Visa en kort variant av receptet
  - [x] Sequel-modell
  - [x] Spara recept
    - [x] Collections
      - [x] Lägg till collection
      - [x] Spara i collection - många till många mellan sparade recept och collections
      - [x] Ta bort collection
  - [x] Ingredienser
    - [x] Egen tabell
- [ ] Sök
  - [ ] Sök bland recept m.h.a taggar och ingredienser
  - [x] Filter
- [x] Användare
  - [x] Inlogg med Google
  - [x] Profilsida
    - [x] Prototyp
- [ ] Taggar
  - [x] Automatiska recepttaggar
- [x] Grupper
  - [x] Gruppsida
  - [x] Visa grupprecept
  - [x] Visa gruppmedlemmar
  - [x] Bjuda in medlemmar
  - [x] publika eller privata
  - [x] Grupprecept
    - [x] Gruppcollections
- [ ] Kategorier
  - [ ] Filtrera bland kategorier
  - [ ] Inte helt säker om jag ska ersätta kategorier helt med taggar
- [ ] Betyg
  - [ ] Genomsnittsrating
- [ ] Error handling
  - [x] 404
  - [x] 401
  - [x] 403?
  - [ ] 

## Routes typ

```
.
├── /api
│   └── /v1
│       ├── /collections
│       │   ├── GET /
│       │   ├── POST /
│       │   ├── PUT /:id
│       │   └── DELETE /:id
│       ├── /recipes
│       │   ├── /:id
│       │   │   ├── /comments
│       │   │   │   ├── GET /
│       │   │   │   ├── POST /
│       │   │   │   └── DELETE /:id
│       │   │   ├── GET /save
│       │   │   └── GET /saved
│       │   ├── GET /check
│       │   ├── POST /
│       │   └── POST /filter
│       ├── POST /comments
│       └── POST /invites
├── /auth
│   ├── /google
│   │   ├── GET /
│   │   └── GET /callback
│   ├── GET /signin
│   └── GET /signout
├── /groups
│   ├── /:id
│   │   ├── GET /
│   │   ├── POST /join
│   │   └── GET /leave
│   ├── GET /
│   ├── POST /
│   └── GET /new
├── /invites
│   ├── POST /
│   └── GET /new
├── /invite
│   └── /:token
│       ├── GET /
│       └── GET /accept
├── /recipes
│   ├── GET /new
│   ├── GET /manual
│   ├── POST /manual
│   ├── GET /:id
│   └── GET /
├── /profile
│   └── /:id
│       ├── GET /
│       ├── GET /bookmarks
│       ├── GET /groups
│       └── GET /collections
├── GET /
└── GET /logout
```