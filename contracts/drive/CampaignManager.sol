pragma solidity ^0.4.18;

import './ControlledTokenTrade.sol';

contract CampaignManager is ControlledTokenTrade {

    uint    public  token_price;
    uint    public  winner_reward;
    uint    public  max_lifetime;

    function CampaignManager(   ERC721 _asset_token,
                                ERC20 _unit_token,
                                uint _token_price,
                                uint _winner_reward,
                                uint _max_lifetime)
                ControlledTokenTrade(_asset_token, _unit_token) public {

         require(_token_price>0);
         require(_winner_reward>0);
         require(_winner_reward<=_token_price);
         require(_max_lifetime>0);

         token_price = _token_price;
         max_lifetime = _max_lifetime;
         winner_reward = _winner_reward;
    }

    function createDeal(uint _tokenId, uint _expiration) public {
        require( _expiration <= now + max_lifetime);
        super.createDeal( _tokenId,  _expiration);

        require(unit_token.transferFrom(msg.sender, this, token_price) );
        make_contribution( msg.sender, token_price,  _tokenId);
        Contributed(msg.sender, asset_token, _tokenId, token_price);

    }

    function calculate_payout(Deal storage _deal, address _sender) internal view returns(uint256) {

        if(_sender==_deal.dealer){
            return 0;
        }

        uint amount = _deal.contributions[_sender];
        if(amount>0){
            amount = amount.add( amount.mul( token_price.sub(winner_reward) ) / _deal.deposited_amount.sub(token_price));
        }

        if(_sender==_deal.winner){
            amount = amount.add(winner_reward);
        }

        return amount;
    }

}