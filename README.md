# Decentralized Financial Planning Scenario Modeling System

A comprehensive blockchain-based system for financial scenario planning, modeling, and decision support built on the Stacks blockchain using Clarity smart contracts.

## Overview

This system provides a decentralized platform for financial planning through five interconnected smart contracts that handle scenario validation, model development, simulation coordination, analysis management, and decision support.

## Architecture

### Core Contracts

1. **Scenario Planner Verification** (`scenario-planner.clar`)
    - Validates financial scenario planners
    - Manages planner credentials and permissions
    - Tracks planner performance metrics

2. **Model Development** (`model-development.clar`)
    - Develops and stores financial models
    - Manages model parameters and configurations
    - Handles model versioning and updates

3. **Simulation Coordination** (`simulation-coordination.clar`)
    - Coordinates scenario simulations
    - Manages simulation queues and execution
    - Tracks simulation results and status

4. **Analysis Management** (`analysis-management.clar`)
    - Manages scenario analysis workflows
    - Stores analysis results and reports
    - Provides analysis aggregation functions

5. **Decision Support** (`decision-support.clar`)
    - Supports scenario-based decision making
    - Provides recommendation algorithms
    - Manages decision tracking and outcomes

## Features

- Decentralized planner verification system
- Comprehensive financial model development tools
- Automated simulation coordination
- Advanced analysis management capabilities
- Intelligent decision support mechanisms
- Risk assessment and validation
- Performance tracking and metrics
- Secure data storage and access control

## Data Types

### Core Data Structures

- **Planner**: Financial planner profile with credentials
- **Model**: Financial model with parameters and metadata
- **Simulation**: Simulation configuration and results
- **Analysis**: Analysis workflow and results
- **Decision**: Decision record with supporting data

## Usage

### Planner Registration
\`\`\`clarity
(contract-call? .scenario-planner register-planner "John Doe" u5)
\`\`\`

### Model Creation
\`\`\`clarity
(contract-call? .model-development create-model "Retirement Planning" u1000000 u30)
\`\`\`

### Simulation Execution
\`\`\`clarity
(contract-call? .simulation-coordination run-simulation u1 u100)
\`\`\`

## Security Features

- Input validation and sanitization
- Access control and permissions
- Risk level assessments
- Error handling and recovery
- Data integrity checks

## Testing

The system includes comprehensive tests using Vitest framework covering:
- Contract deployment and initialization
- Core functionality testing
- Error handling validation
- Integration testing
- Performance benchmarks

## Configuration

- Clarinet.toml for blockchain configuration
- Package.json for development dependencies
- Test configurations for automated testing

## Getting Started

1. Install dependencies: \`npm install\`
2. Deploy contracts: \`clarinet deploy\`
3. Run tests: \`npm test\`
4. Start development: \`npm run dev\`
