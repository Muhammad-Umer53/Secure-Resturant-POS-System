# Secure Restaurant POS System

A console-based **Restaurant Point of Sale (POS) System** developed in
**x86 Assembly Language** using **MASM** and the **Irvine32 library**.
This project was created as part of the **Computer Organization and
Assembly Language (COAL)** university course.

The application demonstrates how low-level Assembly concepts can be used
to build a menu-driven system with role-based access, order processing,
bill calculation, payment handling, and sales reporting.

------------------------------------------------------------------------

## Table of Contents

-   [Overview](#overview)
-   [Features](#features)
-   [User Roles](#user-roles)
-   [Restaurant Menu](#restaurant-menu)
-   [How the System Works](#how-the-system-works)
-   [Assembly Concepts Demonstrated](#assembly-concepts-demonstrated)
-   [Technologies Used](#technologies-used)
-   [Project Structure](#project-structure)
-   [Requirements](#requirements)
-   [Build and Run](#build-and-run)
-   [Demo Credentials](#demo-credentials)
-   [Limitations](#limitations)
-   [Team Members](#team-members)
-   [Course Information](#course-information)
-   [Disclaimer](#disclaimer)

------------------------------------------------------------------------

## Overview

The Secure Restaurant POS System simulates the basic workflow of a
restaurant counter. A cashier can create customer orders, manage the
cart, generate bills, and record payments. A manager has access to sales
reports and can change the cashier password after completing manager
re-authentication.

The project is designed as an educational demonstration of Assembly
Language programming. It uses arrays, procedures, loops, conditional
jumps, arithmetic instructions, registers, and memory addressing to
perform its operations.

## Features

### Authentication and Access Control

-   Separate login access for Cashier and Manager.
-   Password verification using a simple 32-bit polynomial-style rolling
    hash.
-   Three incorrect login attempts before a 15-second lock delay.
-   Manager re-authentication before changing the cashier password.
-   Cashier and manager menus provide different operations.

### Order Management

-   Add items to the current order.
-   Enter quantities for selected items.
-   View the current cart.
-   Remove a selected quantity from an item.
-   Prevent removal from reducing an item's quantity below zero.
-   Cancel the current order.
-   Generate a bill for the current cart.

### Billing and Payment

-   Calculate the order subtotal.
-   Apply 5% GST.
-   Display the final bill.
-   Support three payment selections: Cash, Card, and Mobile Wallet
    (Easypaisa).
-   Check whether the cash received is sufficient.
-   Calculate and display change for cash payments.

### Manager Dashboard

-   View quantities sold for each menu item.
-   View total sales grouped by payment method.
-   View overall sales.
-   Identify the best-selling item.
-   Change the cashier password after manager verification.

## User Roles

  -----------------------------------------------------------------------
  Role                                Available Operations
  ----------------------------------- -----------------------------------
  **Cashier**                         Create orders, add items, view
                                      cart, remove items, cancel orders,
                                      generate bills, process payment,
                                      logout, and exit.

  **Manager**                         View sales report, change cashier
                                      password after re-authentication,
                                      logout, and exit.
  -----------------------------------------------------------------------

The manager menu does not include the new-order option.

## Restaurant Menu

The application currently contains five predefined menu items:

    Item No. Item             Price
  ---------- ------------ ---------
           1 Pizza          Rs. 300
           2 Burger         Rs. 150
           3 Tea             Rs. 50
           4 Cold Drink      Rs. 80
           5 Fries          Rs. 100

### Bill Calculation

``` text
Subtotal = Sum of (Item Quantity × Item Price)
GST = (Subtotal × 5) / 100
Final Total = Subtotal + GST
```

**Note:** GST is calculated using integer arithmetic, so any fractional
part is discarded.

## How the System Works

1.  The program displays the welcome screen and asks the user to enter a
    password.
2.  The entered password is processed by the `SimpleHash` procedure.
3.  The generated hash is compared with the stored cashier and manager
    hashes.
4.  After successful authentication, the appropriate role-based menu is
    displayed.
5.  The cashier can create an order, manage the cart, generate a bill,
    and select a payment method.
6.  After successful payment, the program updates the item quantities
    sold and sales totals.
7.  The manager can view the sales report or change the cashier password
    after re-authentication.
8.  The user can log out to return to the login screen or exit the
    application.

## Assembly Concepts Demonstrated

The project applies the following concepts in its actual implementation:

  -----------------------------------------------------------------------
  Concept                             Application in the Project
  ----------------------------------- -----------------------------------
  Registers                           EAX, EBX, ECX, EDX, ESI, and EDI
                                      are used for calculations,
                                      input/output, indexing, and data
                                      handling.

  Data Types                          BYTE and DWORD variables are used
                                      for strings, prices, quantities,
                                      hashes, and totals.

  Data Movement                       `MOV` transfers values between
                                      registers and memory.

  Arithmetic Instructions             `ADD`, `SUB`, `IMUL`, `MUL`, and
                                      `DIV` perform calculations and
                                      update totals.

  Comparison                          `CMP` checks passwords, menu
                                      choices, quantities, and role
                                      values.

  Conditional Jumps                   Instructions such as `JE`, `JNE`,
                                      `JB`, `JA`, and `JNZ` control
                                      program decisions.

  Unconditional Jump                  `JMP` transfers execution between
                                      program labels.

  Loops                               `LOOP` and conditional jump-based
                                      loops process arrays and repeat
                                      menu operations.

  Procedures                          `CALL` and `RET` organize the
                                      program into reusable procedures.

  Stack Operations                    `PUSH`, `POP`, `PUSHAD`, and
                                      `POPAD` preserve register values.

  Arrays                              Arrays store item names, prices,
                                      cart quantities, sold quantities,
                                      and payment totals.

  Macros                              The `PRINT` macro simplifies
                                      repeated console output operations.

  String Handling                     Password buffers and
                                      null-terminated strings are
                                      processed in memory.

  Input/Output                        Irvine32 procedures handle console
                                      input, output, and delay
                                      operations.

  Memory Addressing                   Indexed addressing is used to
                                      access array elements.
  -----------------------------------------------------------------------

The submitted source uses `MOV` for data movement; it does not implement
`XCHG`. Concepts not present in the source code are not claimed as
implemented features.

## Technologies Used

-   **Language:** x86 Assembly
-   **Assembler:** MASM
-   **Library:** Irvine32
-   **Development Environment:** \[Add your IDE and version\]
-   **Platform:** Windows

## Project Structure

Update this section if your final repository contains additional files
or folders.

``` text
Secure-Restaurant-POS-System/
│
├── source.asm          # Main Assembly source code
├── README.md           # Project documentation
└── [additional files]  # Add build scripts or project files, if included
```

## Requirements

To assemble and run this project, you need:

-   A Windows environment.
-   MASM (Microsoft Macro Assembler).
-   Irvine32 library configured correctly.
-   A compatible linker and the required Irvine32 support files.
-   An IDE or command-line build environment configured for MASM.

## Build and Run

1.  Clone or download this repository:

    ``` bash
    git clone [YOUR_REPOSITORY_URL]
    ```

2.  Open the project in your configured MASM development environment.

3.  Make sure the Irvine32 include and library paths are configured
    correctly.

4.  Assemble and link `source.asm` using your configured MASM/Irvine32
    setup.

5.  Run the generated executable from the configured environment.

**Important:** The exact build commands depend on how MASM and Irvine32
are installed and configured on your computer. Add your tested build
command or build script here if you want contributors to reproduce your
setup.

## Demo Credentials

The source code contains these initial demonstration credentials:

  Role      Initial Password
  --------- ------------------
  Cashier   `1234`
  Manager   `9999`

The manager can change the cashier password from the manager menu.

> **Security warning:** These are demonstration credentials for a
> university project. The password hashing routine is a simple 32-bit
> rolling hash, not a secure password-storage algorithm. Do not use this
> authentication design to protect a real business system.

## Limitations

This version is intended for learning and demonstration. Its current
limitations include:

-   Sales data and password hashes are stored in memory and reset when
    the program exits.
-   Menu items and prices are predefined in the source code.
-   There is no database or file-based transaction history.
-   Card and mobile-wallet payments are simulated; no external payment
    service is connected.
-   Inventory and stock management are not included.
-   The application is designed for a single local console session.
-   The password hash is not suitable for production security.
-   GST uses integer arithmetic, so fractional amounts are truncated.

## Team Members

  Name                Roll Number       Contribution
  ------------------- ----------------- ------------------
  \[Team Member 1\]   \[Roll Number\]   \[Contribution\]
  \[Team Member 2\]   \[Roll Number\]   \[Contribution\]
  \[Team Member 3\]   \[Roll Number\]   \[Contribution\]

## Course Information

  -----------------------------------------------------------------------
  Detail                              Information
  ----------------------------------- -----------------------------------
  University                          FAST National University of
                                      Computer and Emerging Sciences

  Campus                              Karachi

  Course                              Computer Organization and Assembly
                                      Language (COAL)

  Course Code                         EL-2003

  Semester                            Fall 2026

  Section                             \[Your Section\]

  Instructor                          Mr. Abdullah Shaikh
  -----------------------------------------------------------------------

## Disclaimer

This project was developed for academic purposes as part of a university
COAL course. It demonstrates fundamental Assembly Language programming
concepts through a simplified restaurant POS workflow. It is not
intended to be deployed as a production restaurant management or payment
system.
