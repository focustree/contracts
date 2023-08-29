This a work in progress. Don't use in production.

# Dev Setup

1. Fetch test account on goerli

```
starkli account fetch --network  goerli-1 0x05161ae78b651b239167b3ed0c1b2f09983cbd9ff433c14fb31472ce8008ac1d --output ~/.starkli/braavos_test_account.json
```

2. Build project

```
scarb build
```

3. Declare `GardenTile` contract

```
starkli declare target/dev/focustree_GardenTile.sierra.json --account ~/.starkli/braavos_test_account.json --private-key $BRAAVOS_TEST_PRIVATE_KEY
```
