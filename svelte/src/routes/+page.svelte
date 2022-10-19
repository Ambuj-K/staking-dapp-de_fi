<script>
    import WalletConnect from "../lib/WalletConnect.svelte";
    import contractAbi from "../contracts/Staking.json";
    const contractAddr =  "0xCe743AD4F0b24c7238257e0E2f515448C87CC4b5";
    export let web3Props = {
        provider : null,
        signer : null,
        account : null,
        chainId : null
    };
</script>

<div class="OUTER">
<h1>Staking App</h1>
</div>
{#if !web3Props.account}
<WalletConnect bind:web3Props {contractAddr} {contractAbi} />
{:else}
Staking work in Progress.
<br/>

{/if}