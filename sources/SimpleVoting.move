module advmaths_addr::SimpleVoting {
    use aptos_framework::signer;
    use std::vector;
    
    struct Poll has store, key {
        title: vector<u8>,     
        yes_votes: u64,        
        no_votes: u64,         
        is_active: bool,       
    }
    
    struct VoteRecord has store, key {
        voted_polls: vector<address>, 
    }
    
    public fun create_poll(creator: &signer, title: vector<u8>) {
        let poll = Poll {
            title,
            yes_votes: 0,
            no_votes: 0,
            is_active: true,
        };
        move_to(creator, poll);
    }
    
    public fun cast_vote(voter: &signer, poll_owner: address, vote_yes: bool) acquires Poll, VoteRecord {
        let poll = borrow_global_mut<Poll>(poll_owner);
        
        assert!(poll.is_active, 1);
        
        let voter_addr = signer::address_of(voter);
        if (!exists<VoteRecord>(voter_addr)) {
            let vote_record = VoteRecord {
                voted_polls: vector::empty<address>(),
            };
            move_to(voter, vote_record);
        };
        
        let vote_record = borrow_global_mut<VoteRecord>(voter_addr);
        
        assert!(!vector::contains(&vote_record.voted_polls, &poll_owner), 2);
        
        if (vote_yes) {
            poll.yes_votes = poll.yes_votes + 1;
        } else {
            poll.no_votes = poll.no_votes + 1;
        };
        
        vector::push_back(&mut vote_record.voted_polls, poll_owner);
    }

}
