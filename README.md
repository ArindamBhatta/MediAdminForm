                   ┌───────────────────────┐
                   │         UI            │
                   │ (Widget / ViewModel)  │
                   └───────────┬───────────┘
                               │
                        calls CRUD methods
                               │
                   ┌───────────▼───────────┐
                   │    SectionRepo<T>     │
                   │  (singleton repo)     │
                   └───────────┬───────────┘
                               │
                        uses mixin logic
                               │
                   ┌───────────▼───────────┐
                   │   FormRepoMixin<T>    │
                   │  - items cache        │
                   │  - newlyAddedItemId   │
                   │  - emitData()         │
                   └───────────┬───────────┘
                               │
                         delegates CRUD
                               │
                   ┌───────────▼───────────┐
                   │  SectionService<T>    │
                   │  (Firestore + CF)     │
                   └───────────┬───────────┘
                               │
                      talks to backend
                               │
        ┌──────────────────────▼─────────────────────────┐
        │             Firebase / Cloud Functions         │
        │  - Firestore collections (CRUD storage)        │
        │  - getNextCategoryId() callable function       │
        └───────────────────────────────────────────────┘

1. UI Layer
   final repo = SectionRepo<MyModel>(myService);
   await repo.create(myItem);

2. SectionRepo
   class SectionRepo<T extends DataModel> with FormRepoMixin<T> {

   }

SectionRepo doesn’t override create() → it inherits the implementation from FormRepoMixin.
So the call moves into `FormRepoMixin.create().`

- Backtracking

1. Service talks to Firestore `returned ID`

```
        final data = newItem.toJson();
        int nextId = await getNextCategoryId(_collectionName);
        data['id'] = nextId.toString();           // custom logical ID
        await _firestore.collection(_collectionName).add(data);
        return data['id'] as String;              // returned ID

```

2. Firestore snapshot listener
   - Firestore notifies when the new document is added. `emitData(items)`

```
_firestore.collection(_collectionName).snapshots().listen((snapshot) {
  final items = snapshot.docs.map((doc) => _fromJson(doc.data())).toList();
  emitData(items); // service emits the full list
});

```

The id field (your custom ID) is part of the document data, so it gets reconstructed into a T model via \_fromJson.

- This means repo.items will contain the new object with the same id

3. Repo uses newlyAddedItemId

```

String? addedItemId = items.any((item) => item.uid == newlyAddedItemId)
? newlyAddedItemId
: null;
emitData(items, addedItemId: addedItemId);

```

- Repo checks: does the newly created ID actually exist in my local list now?

- If yes → it emits the data stream with addedItemId, so UI knows “this is the one you just created.”

- Then newlyAddedItemId is reset to null

```
┌───────────────────────┐
│         UI            │
│  - calls create()     │
│  - receives new ID    │
│  - later listens to   │
│    repo.dataStream    │
└───────────────────────┘
            ▲
            │ (ID returned immediately)
            │
┌───────────────────────┐
│   FormRepoMixin<T>    │
│  - create() stores    │
│    newlyAddedItemId   │
│  - waits for snapshot │
│  - emitData(items,    │
│    addedItemId)       │
└───────────────────────┘
            ▲
            │ (new items pushed)
            │
┌───────────────────────┐
│   SectionService<T>   │
│  - writes to Firestore│
│  - listens snapshots  │
│  - emitData(items)    │
└───────────────────────┘
            ▲
            │ (new document added)
            │
┌───────────────────────────────┐
│   Firebase / Cloud Functions  │
│  - Firestore assigns docId    │
│  - stores custom 'id' field   │
│  - snapshot triggers          │
└───────────────────────────────┘


```

1. firebase version

2. firebase setup:emulators:firestore

3. firebase project:list

4. dart pub global activate flutterfire_cli

dart pub global run flutterfire_cli:flutterfire configure --project=baisakhi-enterprise-vet-clinic --platforms=web
