// ~/.finicky.ts
import type { FinickyConfig, BrowserSpecification } from "/Applications/Finicky.app/Contents/Resources/finicky.d.ts";

const personal = { name: "Helium", profile: "Personal" } satisfies BrowserSpecification;
const work = { name: "Helium", profile: "Work" } satisfies BrowserSpecification;

export default {
  defaultBrowser: personal,
  handlers: [
    {
      match: (_url, { opener }) => [
        "Microsoft Outlook",
        "Slack",
      ].includes(opener!.name),
      browser: work,
    },
    {
      match: (url) => [
        "jira.kowitops.com"
      ].includes(url.host),
      browser: work,
    },
  ],
} satisfies FinickyConfig;
