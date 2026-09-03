`timescale 1ns/1ps

module tb_atm_controller;

    //====================================================
    // INPUT SIGNALS
    //====================================================

    logic        clk;
    logic        reset;

    logic        card_inserted;

    logic [3:0]  pin;
    logic        pin_valid;

    logic        balance_req;
    logic        withdraw_req;
    logic        deposit_req;
    logic        exit_req;

    logic [15:0] amount;


    //====================================================
    // OUTPUT SIGNALS
    //====================================================

    logic        card_eject;
    logic        pin_error;
    logic        account_locked;
    logic        insufficient_funds;
    logic        transaction_done;

    logic [15:0] balance;


    //====================================================
    // DUT
    //====================================================

    atm_controller uut (

        .clk(clk),
        .reset(reset),

        .card_inserted(card_inserted),

        .pin(pin),
        .pin_valid(pin_valid),

        .balance_req(balance_req),
        .withdraw_req(withdraw_req),
        .deposit_req(deposit_req),
        .exit_req(exit_req),

        .amount(amount),

        .card_eject(card_eject),
        .pin_error(pin_error),
        .account_locked(account_locked),
        .insufficient_funds(insufficient_funds),
        .transaction_done(transaction_done),

        .balance(balance)

    );


    //====================================================
    // CLOCK
    //====================================================

    always #5 clk = ~clk;


    //====================================================
    // TEST
    //====================================================

    initial begin

        // Initial values
        clk = 1'b0;
        reset = 1'b1;

        card_inserted = 1'b0;

        pin = 4'b0000;
        pin_valid = 1'b0;

        balance_req = 1'b0;
        withdraw_req = 1'b0;
        deposit_req = 1'b0;
        exit_req = 1'b0;

        amount = 16'd0;


        //================================================
        // RESET
        //================================================

        #10;
        reset = 1'b0;


        //================================================
        // INSERT CARD
        //================================================

        #10;
        card_inserted = 1'b1;

        #10;
        card_inserted = 1'b0;


        //================================================
        // ENTER CORRECT PIN
        // PIN = 1010
        //================================================

        #10;
        pin = 4'b1010;
        pin_valid = 1'b1;

        #10;
        pin_valid = 1'b0;


        //================================================
        // CHECK BALANCE
        //================================================

        #10;
        balance_req = 1'b1;

        #10;
        balance_req = 1'b0;

        #10;

        $display("--------------------------------");
        $display("Current Balance = %0d", balance);
        $display("--------------------------------");


        //================================================
        // WITHDRAW 2000
        //================================================

        #10;
        amount = 16'd2000;
        withdraw_req = 1'b1;

        #10;
        withdraw_req = 1'b0;

        #10;

        $display("--------------------------------");
        $display("After Withdrawal = %0d", balance);
        $display("--------------------------------");


        //================================================
        // DEPOSIT 3000
        //================================================

        #10;
        amount = 16'd3000;
        deposit_req = 1'b1;

        #10;
        deposit_req = 1'b0;

        #10;

        $display("--------------------------------");
        $display("After Deposit = %0d", balance);
        $display("--------------------------------");


        //================================================
        // EXIT ATM
        //================================================

        #10;
        exit_req = 1'b1;

        #10;
        exit_req = 1'b0;

        #20;

        $display("--------------------------------");
        $display("ATM Simulation Completed");
        $display("--------------------------------");

        $finish;

    end

endmodule