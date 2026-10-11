# Executive Summary — Neuro Wellness Dojo

## What it is

Neuro Wellness Dojo is a referral landing page for a coaching practice that
teaches relaxation skills drawn from somatic disciplines — aikido, and related
mind/body practices. The current campaign targets dental-anxiety patients
referred by a specific dentist, but the structure fits any somatic studio or
movement-arts practice (yoga, tai chi, dance, aikido) that needs a controlled
intake funnel.

## What it provides to a somatic practice

- **A referral-gated intake funnel.** An access code unlocks the full landing
  page and intake form. A studio can give the code to a referring partner and
  control who enters the pipeline, without running a user account system.
- **Intake without a database.** Submissions arrive by email and are logged
  to a Google Sheet. The practitioner gets a structured record of every lead
  with no database to maintain.
- **Message testing built in.** A server-side A/B test swaps key wording
  (e.g. "somatic practice" vs. "mind/body practice") and records which
  variant each visitor saw. A studio can measure which language converts
  referrals into bookings — a common open question in movement-arts
  marketing, where terminology varies by field.
- **Low operating cost.** Plain PHP on shared hosting. No framework, no
  JavaScript, no build step, no paid APIs. A non-technical operator can run
  it.
- **Reusable as a template.** The pages, form handler, A/B logic, and Sheet
  webhook are small and self-contained. The same structure can serve any
  studio that wants a referral landing page with a contact form and basic
  conversion tracking.

## What it does not provide

- No scheduling, payments, or user accounts.
- No analytics dashboard; A/B results are compared manually in the Sheet.
- The access-code gate is a session flag, not real authentication.
