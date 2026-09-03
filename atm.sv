`timescale 1ns/1ps

module atm_controller (
    input  logic        clk,
    input  logic        reset,

    // Card
    input  logic        card_inserted,

    // PIN
    input  logic [3:0]  pin,
    input  logic        pin_valid,

    // ATM operations
    input  logic        balance_req,
    input  logic        withdraw_req,
    input  logic        deposit_req,
    input  logic        exit_req,

    // Transaction amount
    input  logic [15:0] amount,

    // Outputs
    output logic        card_eject,
    output logic        pin_error,
    output logic        account_locked,
    output logic        insufficient_funds,
    output logic        transaction_done,

    // Account balance
    output logic [15:0] balance
);

    //====================================================
    // FSM STATES
    //====================================================

    typedef enum logic [3:0] {
        IDLE,
        PIN_CHECK,
        MENU,
        BALANCE_CHECK,
        WITHDRAW,
        DEPOSIT,
        EJECT,
        LOCKED
    } state_t;

    state_t state;
    state_t next_state;

    // Dummy PIN for simulation
    localparam logic [3:0] CORRECT_PIN = 4'b1010;

    // Number of wrong PIN attempts
    logic [1:0] wrong_attempts;


    //====================================================
    // STATE REGISTER AND OUTPUT LOGIC
    //====================================================

    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin

            state               <= IDLE;
            balance             <= 16'd10000;
            wrong_attempts      <= 2'd0;

            card_eject          <= 1'b0;
            pin_error           <= 1'b0;
            account_locked      <= 1'b0;
            insufficient_funds  <= 1'b0;
            transaction_done    <= 1'b0;

        end
        else begin

            state <= next_state;

            // Default outputs
            card_eject         <= 1'b0;
            pin_error          <= 1'b0;
            insufficient_funds <= 1'b0;
            transaction_done   <= 1'b0;

            case (state)

                // ----------------------------------------
                // PIN CHECK
                // ----------------------------------------
                PIN_CHECK: begin

                    if (pin_valid) begin

                        if (pin == CORRECT_PIN) begin
                            wrong_attempts <= 2'd0;
                        end
                        else begin

                            pin_error <= 1'b1;

                            if (wrong_attempts < 2'd3)
                                wrong_attempts <= wrong_attempts + 1'b1;

                        end
                    end
                end


                // ----------------------------------------
                // BALANCE
                // ----------------------------------------
                BALANCE_CHECK: begin
                    transaction_done <= 1'b1;
                end


                // ----------------------------------------
                // WITHDRAW
                // ----------------------------------------
                WITHDRAW: begin

                    if (amount <= balance) begin

                        balance <= balance - amount;
                        transaction_done <= 1'b1;

                    end
                    else begin

                        insufficient_funds <= 1'b1;

                    end

                end


                // ----------------------------------------
                // DEPOSIT
                // ----------------------------------------
                DEPOSIT: begin

                    balance <= balance + amount;
                    transaction_done <= 1'b1;

                end


                // ----------------------------------------
                // CARD EJECT
                // ----------------------------------------
                EJECT: begin
                    card_eject <= 1'b1;
                end


                // ----------------------------------------
                // ACCOUNT LOCKED
                // ----------------------------------------
                LOCKED: begin
                    account_locked <= 1'b1;
                end


                default: begin
                end

            endcase

        end

    end


    //====================================================
    // NEXT STATE LOGIC
    //====================================================

    always_comb begin

        next_state = state;

        case (state)

            // ----------------------------------------
            // IDLE
            // ----------------------------------------
            IDLE: begin

                if (card_inserted)
                    next_state = PIN_CHECK;

            end


            // ----------------------------------------
            // PIN CHECK
            // ----------------------------------------
            PIN_CHECK: begin

                if (wrong_attempts >= 2'd3)
                    next_state = LOCKED;

                else if (pin_valid && (pin == CORRECT_PIN))
                    next_state = MENU;

            end


            // ----------------------------------------
            // MENU
            // ----------------------------------------
            MENU: begin

                if (balance_req)
                    next_state = BALANCE_CHECK;

                else if (withdraw_req)
                    next_state = WITHDRAW;

                else if (deposit_req)
                    next_state = DEPOSIT;

                else if (exit_req)
                    next_state = EJECT;

            end


            // ----------------------------------------
            // BALANCE CHECK
            // ----------------------------------------
            BALANCE_CHECK: begin
                next_state = MENU;
            end


            // ----------------------------------------
            // WITHDRAW
            // ----------------------------------------
            WITHDRAW: begin
                next_state = MENU;
            end


            // ----------------------------------------
            // DEPOSIT
            // ----------------------------------------
            DEPOSIT: begin
                next_state = MENU;
            end


            // ----------------------------------------
            // EJECT
            // ----------------------------------------
            EJECT: begin
                next_state = IDLE;
            end


            // ----------------------------------------
            // LOCKED
            // ----------------------------------------
            LOCKED: begin
                next_state = LOCKED;
            end


            default: begin
                next_state = IDLE;
            end

        endcase

    end

endmodule