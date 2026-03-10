---
name: linkedin-post
description: "LinkedIn post creation skill optimized for engagement and click-through. Use whenever the user asks for a LinkedIn post, says 'share on LinkedIn,' 'promote this article,' 'write a post for,' requests social media promotion, mentions LinkedIn content strategy, or wants to announce something professionally. Also trigger when reviewing or editing existing LinkedIn drafts. This skill creates posts specifically optimized for the LinkedIn algorithm, Noah's voice, and click-through behavior (not just views). Always produces 2 variant posts with different strategic hooks."
---

# LinkedIn Post Creation Skill

Creates LinkedIn posts optimized for engagement, specifically click-through rate (not just impressions). Every post must sound like Noah, pass AI detection, and work with the LinkedIn algorithm.

## Dependencies

- **noah-voice**: Read and apply voice rules before writing. The post must sound like Noah.
- **ai-scoring**: Run the scoring pass on each variant before presenting. LinkedIn posts should score 75+.

Read the `noah-voice` skill's `references/voice-rules.md` and at least skim one example article before writing. Then read `references/linkedin-examples.md` in this skill's directory for patterns from Noah's highest-performing posts.

## LinkedIn Algorithm Rules

### The Fold (Most Critical)
The "see more" fold on mobile is approximately **210 characters** (first 2-3 lines). Everything above that fold determines whether someone reads the rest. The hook must create enough tension, curiosity, or recognition that the reader taps "see more."

**Good hooks from Noah's top posts:**
- "I love using Cursor. It has completely changed how I write code. But recently, I noticed it was gaming my system." (Problem + curiosity)
- "I haven't posted an update on my career search since my original 'I'm looking for work' post." (Curiosity gap)
- "I am incredibly honored to be named a 2026 Snowflake Data Superhero. But as the excitement settles..." (Pivot from expected to unexpected)

**Pattern:** Start with something relatable or expected, then introduce a twist or question in the first 2-3 lines.

### Link Suppression
**NO external links in the post body.** LinkedIn's algorithm actively suppresses posts that contain external URLs. Always end with "Link in comments." or a variation. Place the actual link in a comment immediately after posting.

### Post Structure
1. **Hook** (above the fold, ~210 characters): Personal story or surprising observation
2. **Body**: The substance. Short paragraphs with whitespace between them. But NOT staccato AI-style single-sentence paragraphs. Each paragraph should be 2-4 sentences. The whitespace helps mobile readability without sacrificing depth.
3. **Engagement CTA**: A specific question people can answer from their own experience. Not "What do you think?" (too vague). Instead: "How do you balance the pressure for 'near-term velocity' with the 'inefficient' work of mentoring the next generation?"
4. **Link line**: "Link in comments." or "Links in comments: [emoji] Article [emoji] GitHub Repo"
5. **Hashtags**: 3-5 at the very end. Specific, not broad. Noah's recurring tags: #SnowflakeDataSuperhero #DataEngineering #TheLongGame

### Content Strategy
- **Personal story > professional announcement** for engagement. Noah's career search post outperformed pure technical content because it named specific people and told micro-stories.
- **For article promotion:** Show enough of the story to hook, but cut before the payoff. Make them click for the resolution. Noah's pytest-coverage-impact post explained the problem vividly but made readers click the article for the solution details.
- **Whitespace matters** on mobile. Keep paragraphs short (2-4 sentences). One blank line between paragraphs.

## Output Format

Always produce **2 variants** with meaningfully different strategic hooks. Not just tone variations (casual vs formal). Different angles on why someone should care:

**Variant A:** [Different hook strategy, e.g., personal story angle]
**Variant B:** [Different hook strategy, e.g., technical insight angle]

For each variant, note:
- Hook strategy used
- Character count of the above-fold text
- Suggested hashtags

## Voice Reminders (Quick Checklist)

Before presenting variants:
1. No em dashes
2. No banned words ("genuinely," "straightforward," "navigate," "landscape," "leverage," "delve")
3. Max 1 single-sentence paragraph per post
4. No generic transitions ("Here's the thing," "Let's dive in")
5. Specific details, not vague claims
6. Run ai-scoring and confirm 75+

## What Makes Noah's LinkedIn Voice Different from Article Voice

LinkedIn Noah is slightly more direct and compressed than Article Noah. The metaphors are tighter (one image, not an extended analogy). The personal stakes come faster. But it's still the same person: specific, confident, story-driven, and warm. He names people. He thanks people publicly. He shares vulnerabilities (job searching, admitting mistakes) without performing vulnerability.
