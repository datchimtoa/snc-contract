module snc_contract::snc {
    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    public struct SNC_TOKEN has drop {}

    public struct TreasuryCap has key, store {
        id: UID,
        cap: TreasuryCap<SNC_TOKEN>,
    }

    public struct WithdrawCap has key, store {
        id: UID,
        treasury_address: address,
    }

    fun init(ctx: &mut TxContext) {
        let (treasury_cap, metadata) = coin::create_currency(
            SNC_TOKEN {},
            9,
            b"SNC",
            b"SNC Network Token",
            b"",
            option::none(),
            ctx,
        );
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(
            TreasuryCap {
                id: object::new(ctx),
                cap: treasury_cap,
            },
            tx_context::sender(ctx),
        );
        transfer::public_transfer(
            WithdrawCap {
                id: object::new(ctx),
                treasury_address: tx_context::sender(ctx),
            },
            tx_context::sender(ctx),
        );
    }

    public entry fun mint(
        cap: &mut TreasuryCap,
        amount: u64,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        let coin = coin::mint(&mut cap.cap, amount, ctx);
        transfer::public_transfer(coin, recipient);
    }

    public entry fun burn(
        cap: &mut TreasuryCap,
        coin: Coin<SNC_TOKEN>,
    ) {
        coin::burn(&mut cap.cap, coin);
    }
}
