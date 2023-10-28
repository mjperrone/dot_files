#!/usr/bin/env python3

import argparse
import csv
import datetime
import json
import subprocess

def get_arguments():
    parser = argparse.ArgumentParser(description="Process pull requests from a GitHub repo.")
    parser.add_argument("repo", help="The organization/repository to fetch PRs from.")
    return parser.parse_args()


def get_prs_from_gh(repo):
    # use the gh cli instead of the octokit SDK to avoid figuring out auth for that
    cmd = [
        "gh", "pr", "list", "--state", "merged", "--repo", repo,
        "--json", "author,mergedAt,number,title,url,reviews", "--limit", "100"
    ]
    return json.loads(subprocess.check_output(cmd).decode('utf-8'))

def process_prs(prs):
    # Filter to only PRs since two_weeks_ago
    two_weeks_ago = (datetime.datetime.now() - datetime.timedelta(weeks=2)).isoformat()
    recent_prs = [pr for pr in prs if pr['mergedAt'] > two_weeks_ago]

    for pr in recent_prs:
        # Replace author obj with author.login
        if 'author' in pr:
            pr['author'] = pr['author']['login']

        # Build reviewers list and delete reviews
        pr['reviewers'] = [review['author']['login'] for review in pr.get('reviews', []) if review['author'] is not None]
        pr.pop('reviews', None)

        # Dedupe reviewers and remove self-reviews
        pr['reviewers'] = list(set(reviewer for reviewer in pr['reviewers'] if reviewer != pr['author']))

    return sorted(recent_prs, key=lambda x: (x['author'], x['mergedAt']))

def save_prs_to_csv(prs):
    # Convert to CSV
    with open('prs.csv', 'w', newline='') as csvfile:
        fieldnames = ['author', 'mergedAt', 'number', 'title', 'url', 'reviewers']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for pr in prs:
            row = pr.copy()
            row['reviewers'] = ", ".join(pr['reviewers'])
            writer.writerow(row)
    
    print("Wrote PR csv to 'prs.csv'")

def save_pr_reviewers_to_csv(prs):
    with open('reviewers_prs.csv', 'w', newline='') as csvfile:
        fieldnames = ['reviewer', 'author', 'mergedAt', 'number', 'title', 'url']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for row in prs:
            writer.writerow(row)
    
    print("Wrote PR reviewers csv to 'reviewers_prs.csv'")


def process_reviewer_prs(prs):
    reviewer_rows = []
    for pr in prs:
        for reviewer in pr['reviewers']:
            reviewer_rows.append({
                'reviewer': reviewer,
                'author': pr['author'],
                'mergedAt': pr['mergedAt'],
                'number': pr['number'],
                'title': pr['title'],
                'url': pr['url']
            })
    return sorted(reviewer_rows, key=lambda x: (x['reviewer'], x['mergedAt']))



if __name__ == "__main__":
    args = get_arguments()
    data = get_prs_from_gh(args.repo)
    processed_prs = process_prs(data)
    save_prs_to_csv(processed_prs)
    reviewer_prs = process_reviewer_prs(processed_prs)
    save_pr_reviewers_to_csv(reviewer_prs)
