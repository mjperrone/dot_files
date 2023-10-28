#!/usr/bin/env python3
import re
import os

import typer


app = typer.Typer()


def find_python_projects():
    # find any directory that has a pyproject.toml and poetry.lock in it under this one:
    # return a list of paths to those directories
    cwd = os.getcwd()
    projects = []
    for dir_path, dir_names, files in os.walk(cwd):
        # Remove hidden directories (that start with a dot) so they aren't walked
        dir_names[:] = [d for d in dir_names if not d.startswith(".")]

        if "pyproject.toml" in files and "poetry.lock" in files:
            projects.append(dir_path)
    return projects

@app.command()
def poetry_install_all():
    projects = find_python_projects()
    print(f"Found {len(projects)} projects")
    for project in projects:
        print(f"poetry install in {project}")
        os.system("poetry --directory {project} install")

@app.command()
def install_all(
    package: str = typer.Argument(..., help="Package to install"),
    version_specifier: str = typer.Argument(
        "latest", help="Version specifier to install"
    ),
):
    # todo fix latest
    projects = find_python_projects()
    print(f"Found {len(projects)} projects")
    for project in projects:
        print(f"Installing {package}{version_specifier} in {project}")
        os.chdir(project)
        os.system(f"poetry --directory {project} add {package}{version_specifier}")

def replace_line_in_file(filename: str, starts_with: str, replace_with: str):
    with open(filename, 'r') as file:
        lines = file.readlines()

    with open(filename, 'w') as file:
        for line in lines:
            if line.startswith(starts_with):
                file.write(replace_with)
            else:
                file.write(line)



@app.command()
def update_all(
    package: str = typer.Argument(..., help="Package to install"),
    version_specifier: str = typer.Argument(
        "latest", help="Version specifier to update to"
    ),
):
    # todo fix latest
    projects = find_python_projects()
    print(f"Found {len(projects)} projects")
    for project in projects:
        pyproject_path = f"{project}/pyproject.toml"
        if package in open(pyproject_path).read():
            print(f"Updating {package} = \"{version_specifier}\" in {project}/pyproject.toml")
            replace_line_in_file(pyproject_path, package, f"{package} = \"{version_specifier}\"\n")

            print(f"poetry --directory {project} lock --no-update")
            os.system(f"poetry --directory {project} lock --no-update")
            print(f"poetry --directory {project} install")
            os.system(f"poetry --directory {project} install")
        else:
            print(f"{package} not found in {project}, skiping...")


@app.command()
def delete():
    print("Deleting user: Hiro Hamada")


if __name__ == "__main__":
    app()
