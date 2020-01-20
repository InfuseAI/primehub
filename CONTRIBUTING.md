# Contributing to PrimeHub

Issues and PRs are welcome!

# Developer Certificate of Origin

PrimeHub DCO and signed-off-by process

The PrimeHub project use the signed-off-by language and process used by the Linux kernel, to give us a clear chain of trust for every patch received.

```
By making a contribution to this project, I certify that:

(a) The contribution was created in whole or in part by me and I have the right to submit it under the open source license indicated in the file; or

(b) The contribution is based upon previous work that, to the best of my knowledge, is covered under an appropriate open source license and I have the right under that license to submit that work with modifications, whether created in whole or in part by me, under the same open source license (unless I am permitted to submit under a different license), as indicated in the file; or

(c) The contribution was provided directly to me by some other person who certified (a), (b) or (c) and I have not modified it.

(d) I understand and agree that this project and the contribution are public and that a record of the contribution (including all personal information I submit with it, including my sign-off) is maintained indefinitely and may be redistributed consistent with this project or the open source license(s) involved.
```

## Using the Signed-Off-By Process

We have the same requirements for using the signed-off-by process as the Linux kernel. In short, you need to include a signed-off-by tag in every patch:

```
This is my commit message

Signed-off-by: Random J Developer <random@developer.example.org>
```

Git even has a -s command line option to append this automatically to your commit message:

```
$ git commit -s -m 'This is my commit message'
```

# Setting up development environment
1. Follow the instruction in [getting started](docs/getting_started.md) to install PrimeHub locally.
2. Clone the PrimeHub repo

   ```
   git clone git@github.com:InfuseAI/primehub.git
   cd primehub
   ```

3. Update the chart dependencies

   ```
   helm repo add stable https://kubernetes-charts.storage.googleapis.com/
   helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
   helm dependency update helm/primehub
   ```

4. Install primehub by local chart

   ```
   helm upgrade --install primehub \
       --namespace primehub \
       --values values.yaml \
       --set-file jupyterhub.hub.extraConfig.primehub=./helm/primehub/jupyterhub_primehub.py \
       ./helm/primehub
   ```

# Write Commit message properly

Structure your commit message like this:

From: [https://git-scm.com/book/ch5-2.html](https://git-scm.com/book/ch5-2.html)

> Short (50 chars or less) summary of changes
>
> More detailed explanatory text, if necessary.  Wrap it to about 72
> characters or so.  In some contexts, the first line is treated as the
> subject of an email and the rest of the text as the body.  The blank
> line separating the summary from the body is critical (unless you omit
> the body entirely); tools like rebase can get confused if you run the
> two together.
>
> Further paragraphs come after blank lines.
>
>   - Bullet points are okay, too
>
>   - Typically a hyphen or asterisk is used for the bullet, preceded by a
>    single space, with blank lines in between, but conventions vary here

## **DO**

- Write the summary line and description of what you have done in the imperative mood, that is as if you were commanding someone. Start the line with "Fix", "Add", "Change" instead of "Fixed", "Added", "Changed".
- Always leave the second line blank.
- Line break the commit message (to make the commit message readable without having to scroll horizontally in `gitk`).
- The summary should be meaningful and descriptive.

## **DON'T**

- Don't end the summary line with a period - it's a title and titles don't end with a period.
- Avoid mentioning specific deployments or customers. Instead, describe what problem is solved.

## **Tips**

- If it seems difficult to summarize what your commit does, it may be due to multiple logical changes or bug fixes, that are better split up into several commits using `git add -p`.

## Recommendations

- Use company email to commit. You can set in the project scope by invoking `git config user.email dev@infuseai.io` inside the repository.
- Sign-off your commits. [[Ref](https://github.com/InfuseAI/primehub/blob/master/CONTRIBUTING.md#using-the-signed-off-by-process)]
- Add `Co-authored-by` if you're pairing with someone. [[Ref]](https://help.github.com/en/github/committing-changes-to-your-project/creating-a-commit-with-multiple-authors)

## Examples
### :x: Bad

```
Fix bugs
```

### :white_check_mark: Good
```git
Fix crashloopback issue of phjob controller

- Add TTL handler in phjob_controller.go
- [Other patchs]

Signed-off-by: Ash Wu <hsatac@infuseai.io>
Co-authored-by: Aaron Huang <aaron@infuseai.io>
```
> :white_check_mark:
```git
Update CHANGELOG.md for Job Submission

- Add `Action Require` of Job Submission
- [Other changes]

Signed-off-by: Ash Wu <hsatac@infuseai.io>
Co-authored-by: Aaron Huang <aaron@infuseai.io>
Co-authored-by: Timothy Lee <ctiml@infuseai.io>
```
