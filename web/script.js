/*

Variables :
supplied_tokens
user_tokens_amount
transfert_token_form
    transfert_token_token_id
    transfert_token_receiver_address
user_balance_form
    user_balance_address
token_owner_form
    token_owner_token_id
transactions_table_content

Buttons :
supplied_tokens_btn
user_tokens_btn
mint_token_btn
transactions_table_btn

Divs/result Block :
user_balance_result
token_owner_result
mint_token_result
transfert_token_result
*/

/**
 * Variables declaration
 */

const contractAddress = "0xb447fEB06Ce5A9988C74875C6992D7653b32E37a";
let LogicContract;
let accountAddress = ethereum.selectedAddress;

/** 
 * Async Contract functions (promises)
 * Works when LogicContract is initialized 
 * */
/**
 * Generic function for contract_calls
 * @param {string} method : method on the contract
 * @param {string} tag : css tag to update (without #) 
 * @param  {...any} params : params of the method
 */
function contract_call(method, tag = false, ...params) {
    return new Promise((resolve, reject) => {
        LogicContract.methods[method](...params).call().then(function(data) {
            if(tag) $("#"+tag).text(data);
            resolve(data);
        }).catch(error => reject(error));
    });
}

function contract_call_signed(method, tag = false, from, ...params) {
    return new Promise((resolve, reject) => {
        LogicContract.methods[method](...params).send({ from }).on('receipt', function(data, error){
            if(error) reject(error);
            if(tag) $("#"+tag).text(data);
            resolve(data);
        }).catch((error) => reject(error));
    });
}

/** Functions with loaders */

function getSuppliedTokens() {
    $(this).addClass("loading");
    contract_call('totalSupply', 'supplied_tokens').then(() => $(this).removeClass("loading"));
}

function mintToken() {
    $(this).addClass("loading");
    contract_call_signed('mintToken', false, accountAddress, accountAddress).then((data) => {
        console.log('transaction data : ', data);
        contract_call('totalSupply', 'supplied_tokens').then((tokenId) => {
            $("#mint_token_result").html(`<div class="ui success message">
            <div class="header">
            Token successfully minted
            </div>
            <p>ID of minted token : ${tokenId}</p>
            </div>
            })`);
            $(this).removeClass("loading");
        });
    }).catch(() => {
        $("#mint_token_result").html(`<div class="ui message">
        <div class="header">
        Impossible to mine a new token, maybe you are not the owner of the contract
        </div>
        </div>
        `);
        $(this).removeClass("loading");
    });
}


function transfertTokenForm() {
    $("#transfert_token_form").submit(function (event) {
        let tokenId = $("#transfert_token_token_id").val();
        let receiver = $("#transfert_token_receiver_address").val();
        contract_call_signed('transferFrom', false, accountAddress, accountAddress, receiver, tokenId).then(function(data) {
            $("#transfert_token_result").html(`<div class="ui success message">
            <div class="header">Successfully transfered</div>
            <p>This token have been successfully transfered to ${receiver}</p>
            </div>
            `);
            $('#transfert_token_form').trigger("reset");
        }).catch(function() {
            $("#transfert_token_result").html(`<div class="ui message">
            <div class="header">
            Impossible to make the transfer, maybe this address is wrong or you are not the owner of the token
            </div>
            </div>
            `);
        });
        event.preventDefault();
      });
}

function getUserBalance() {
    $("#user_balance_form").submit(function (event) {
        let user_address = $("#user_balance_address").val();
        contract_call('balanceOf', false, user_address).then(function(data) {
            $("#user_balance_result").html(`<div class="ui message">
            <div class="header"> 
            Balance of ${user_address}
            </div>
            <p>This user have ${data} tokens </p>
            </div>
            `);
            $("#user_balance_form").trigger("reset");
        }).catch(function() {
            $("#user_balance_result").html(`<div class="ui message">
            <div class="header">
            Impossible to retrieve the balance, maybe this address is wrong or do not exists
            </div>
            </div>
            `);
        });
        event.preventDefault();
      });
}

function getOwnerOfToken() {
    $("#token_owner_form").submit(function (event) {
        let tokenId = $("#token_owner_token_id").val();
        contract_call('ownerOf', false, tokenId).then(function(data) {
            contract_call('previousOwner', false, tokenId).then(data => data).catch(() => 'inexistant').then(function(previousOwner) {
                $("#token_owner_result").html(`<div class="ui message">
                <div class="header">
                Owner of token n°${tokenId}
                </div>
                <p>Actual owner is ${data}, previous owner is ${previousOwner}</p>
                </div>
                `);
                $("#token_owner_form").trigger("reset");
            })
        }).catch(function() {
            $("#token_owner_result").html(`<div class="ui message">
            <div class="header">
            Impossible to retrieve the owner, maybe this token do not exists
            </div>
            </div>
            `);
        });
        event.preventDefault();
      });
}

$(document).ready(function () {
    // Connect to Rinkeby network

    // Initialize forms
    transfertTokenForm();
    getUserBalance();
    getOwnerOfToken();

    // Button listeners
    $("#supplied_tokens_btn").click(getSuppliedTokens);
    const loginBtn = $("#enableEthereumButton");
    if(!accountAddress) {
        $('#displayMessage').show();
        $('button').prop("disabled",true);
        loginBtn.prop("disabled",false);
        loginBtn.addClass("orange");
        loginBtn.click(async () => {
            const accounts = await ethereum.request({ method: 'eth_requestAccounts' });
            accountAddress = accounts[0];
            $('#displayMessage').hide();
            $('button').prop("disabled",false);
            loginBtn.addClass("green");
            loginBtn.html('<i class="icon check circle"></i> Connected to MetaMask');
        });
    } else {
        loginBtn.addClass("green");
        loginBtn.html('<i class="icon check circle"></i> Connected to MetaMask');
    }
    $("#mint_token_btn").click(mintToken);

    // MetaMask
    handleMetaMask();
});

function handleMetaMask() {
    window.addEventListener('load', async () => {
        // Modern dapp browsers...
        if (window.ethereum) {
            window.Web3 = new Web3(ethereum);
        } else if (window.Web3) {
            window.Web3 = new Web3(new Web3.providers.WebsocketProvider("wss://rinkeby.infura.io/ws/v3/d8528137024e473d9a4a45b8028c5a82"));
        }
        else {
            console.log('Non-Ethereum browser detected. You should consider trying MetaMask!');
            return;
        }
        try {
            startWeb3Services();
        } catch(error) {

        }
    });
}

async function startWeb3Services() {
    LogicContract = new Web3.eth.Contract(contract, contractAddress);
    LogicContract.methods.name().call().then(result => {
        console.log('Resultat : ', result);
    });

    // Initialize data
    contract_call('totalSupply', 'supplied_tokens');
    contract_call('balanceOf', 'user_tokens_amount', accountAddress);
    /*
    contract_call('owner', false).then(result => {
        if(result == accountAddress) $('#unminable_token_btn').hide()
        else $('#mint_token_btn').hide();
    });
    */
}