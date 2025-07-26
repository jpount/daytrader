# DayTrader Documentation

This branch (gen-doc) demonstrates how to document the current codebase apprpriately

## Pre Reqs if you want to run yourself
* Delete existing CLAUDE.md file
* Delete everything out of the docs/diagrams and docs/ folders
* Run claude /init
* Set up MCPs - see below
* Review tasks in tasks.json and reset every status to `pending` if it's not already

## MCPs
* Copy the mcp.json.example file to the root directory and remove the `.example` suffix
* Add your API keys where appropriate

### Investigation
Used claude code with this prompt to generate the `document-gathering.md` file
```
I want to use claude code on the current directory to completely understand the codebase under the app directory. I want to write extremely comprehensive and accurate documentation in markdown and generate diagrams with in mermaid format. The ultimate goal is to rewrite the application in springboot and angular so I need to ensure I capture all business logics, flows, interactions etc. The docs will got in the docs directory and the diagrams in docs/diagrams. I was thinking of using claude task master to guide the exercise and maybe a database mcp to hold the information generated. Provide the best advice for achieving this and document it in a document-gathering.md file
```

## Running
You can either:

* Create tasks and kick of task master
OR
* Run the scripts to create the docs

