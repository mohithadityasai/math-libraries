module advmaths_addr::SimpleVoting {
    use aptos_framework::signer;
    use std::vector;
    
    /// Struct representing a voting poll
    struct Poll has store, key {
        title: vector<u8>,     // Title of the poll
        yes_votes: u64,        // Number of yes votes
        no_votes: u64,         // Number of no votes
        is_active: bool,       // Whether the poll is still active
    }
    
    /// Struct to track if a user has already voted
    struct VoteRecord has store, key {
        voted_polls: vector<address>,  // List of poll addresses user has voted on
    }
    
    /// Function to create a new voting poll
    public fun create_poll(creator: &signer, title: vector<u8>) {
        let poll = Poll {
            title,
            yes_votes: 0,
            no_votes: 0,
            is_active: true,
        };
        move_to(creator, poll);
    }
    
    /// Function to cast a vote on a poll
    public fun cast_vote(voter: &signer, poll_owner: address, vote_yes: bool) acquires Poll, VoteRecord {
        let poll = borrow_global_mut<Poll>(poll_owner);
        
        // Check if poll is active
        assert!(poll.is_active, 1);
        
        // Initialize vote record if it doesn't exist
        let voter_addr = signer::address_of(voter);
        if (!exists<VoteRecord>(voter_addr)) {
            let vote_record = VoteRecord {
                voted_polls: vector::empty<address>(),
            };
            move_to(voter, vote_record);
        };
        
        let vote_record = borrow_global_mut<VoteRecord>(voter_addr);
        
        // Check if user has already voted on this poll
        assert!(!vector::contains(&vote_record.voted_polls, &poll_owner), 2);
        
        // Record the vote
        if (vote_yes) {
            poll.yes_votes = poll.yes_votes + 1;
        } else {
            poll.no_votes = poll.no_votes + 1;
        };
        
        // Mark that user has voted on this poll
        vector::push_back(&mut vote_record.voted_polls, poll_owner);
    }
}