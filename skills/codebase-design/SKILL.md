---
name: codebase-design
description: Shared vocabulary and checks for designing deep modules. Use when the user wants to design or improve a module's interface, find deepening opportunities, decide where a seam goes, make code more testable or AI-navigable, or when another skill needs the deep-module vocabulary (module, interface, depth, seam, adapter, leverage, locality).
---

# Codebase Design

Design **deep modules**: a lot of behaviour behind a small interface, placed at a real seam, tested through that interface. Use this vocabulary wherever code is being designed or restructured. The payoff is **leverage** for callers, **locality** for maintainers (human or agent), and testability for both.

## Glossary

Use these terms exactly. Don't substitute "component", "service", "API", "signature", "unit", or "boundary": consistent language is the point.

**Module**: anything with an interface and an implementation. Deliberately scale-agnostic: a function, a class, a package, a tier-spanning slice. _Avoid_: unit, component, service.

**Interface**: everything a caller must know to use the module correctly: the signature, plus invariants, ordering constraints, error modes, required configuration, performance characteristics, and whatever the docs promise. If a caller must read the implementation to use the module safely, the interface is bigger than its types suggest. _Avoid_: API, signature (both name only the type-level surface).

**Implementation**: everything inside the module that the interface hides. May itself be composed of smaller modules.

**Depth**: leverage at the interface: how much behaviour a caller or test can exercise per unit of interface they must learn. **Deep** = lots of behaviour behind a small interface. **Shallow** = an interface nearly as complex as what it hides.

**Pass-through**: a module whose interface is nearly identical to that of the module it delegates to. Adds interface without adding behaviour: the canonical shallow module.

**Seam** _(Feathers)_: a place where you can alter behaviour without editing in that place. Here: the location where a module's interface lives and where adapters can be swapped. Where a seam goes is a design decision separate from what goes behind it. _Avoid_: boundary (overloaded with DDD's bounded context).

**Enabling point** _(Feathers)_: where the choice of adapter is made: a constructor argument, a factory, a wiring module. Every real seam has one. If you can't point to it, the seam is hypothetical.

**Adapter**: a concrete thing that satisfies an interface at a seam. Names a *role*, not substance: a Postgres repository is an adapter with a large implementation behind it; an in-memory fake is an adapter with almost nothing behind it. Both fill the same slot. Say "adapter" when the seam is the topic, "implementation" otherwise.

**Leverage**: what callers get from depth: more capability per unit of interface learned. One implementation pays back across N call sites and M tests.

**Locality**: what maintainers get from depth: change, bugs, knowledge, and verification concentrate in one place. Fix once, fixed everywhere. Locality is also what makes code navigable for an agent: one place to read, one place to edit.

## Deep vs shallow

```
Deep (aim for this): small interface, lots hidden

┌─────────────────────┐
│   Small interface   │  ← few entry points, simple params, few error modes
├─────────────────────┤
│                     │
│ Deep implementation │  ← complexity lives here, in one place
│                     │
└─────────────────────┘

Shallow (avoid): interface nearly as big as what it hides

┌─────────────────────────────────┐
│         Large interface         │  ← many methods, complex params, config pushed to callers
├─────────────────────────────────┤
│       Thin implementation       │  ← mostly delegation
└─────────────────────────────────┘
```

## Principles

- **Depth comes from information hiding.** Each design decision (storage format, retry policy, ordering, encoding) should be known by exactly one module. When two modules both need the same fact, that's **information leakage**: the interface between them is bigger than it looks.
- **Depth is a property of the interface, not the implementation.** A deep module can be built from small, swappable parts internally; they just aren't part of the interface. A module can have **internal seams** (private to its implementation, used by its own tests) as well as the **external seam** at its interface.
- **Pull complexity downward.** When complexity must live somewhere, put it in the implementation, not the interface. Better for one implementer to carry it than every caller.
- **The deletion test.** Imagine deleting the module. If complexity vanishes, it was a pass-through. If complexity reappears across N callers, it was earning its keep.
- **The interface is the test surface.** Callers and tests cross the same seam. If you want to test *past* the interface, either the module is the wrong shape or it's missing an internal seam.
- **One adapter means a hypothetical seam. Two means a real one.** A test fake counts: production adapter + fake is a real seam. Production adapter + nothing is an interface in search of a reason. Don't introduce a seam until something actually varies across it.

## Interface checklist

Run these over any interface you're designing or reviewing:

1. Can I remove an entry point? Merge methods that are always called together.
2. Can I remove a parameter? Default it, derive it, or move the decision inside.
3. Can I define an error out of existence? Make the edge case succeed instead of reporting it (deleting a missing file is a no-op; a substring range clips instead of throwing).
4. Does the caller need to know an ordering? "Call A before B" is interface. Can the module sequence it?
5. Does the caller need a fact the module should own (storage, retry, caching, encoding)? If so, information is leaking.
6. Where is the enabling point, and does anything actually vary there?

## Designing for testability

Testability falls out of the interface. Three habits:

1. **Accept dependencies, don't create them.** Creating a collaborator inside the module buries the enabling point.

   ```typescript
   // Enabling point is the parameter: tests pass a fake
   function processOrder(order: Order, gateway: PaymentGateway) {}

   // No enabling point: tests must hit Stripe
   function processOrder(order: Order) {
     const gateway = new StripeGateway();
   }
   ```

2. **Separate deciding from doing.** Return the decision; let a thin edge apply it. Decisions are cheap to assert on; effects need setup, mutation, and inspection.

   ```typescript
   // Decision: pure, assert on the return value
   function calculateDiscount(cart: Cart): Discount {}

   // Decision tangled with effect: build a cart, mutate it, inspect it
   function applyDiscount(cart: Cart): void {
     if (cart.items.length > 5) cart.total *= 0.9;
   }
   ```

3. **Test through the interface; replace adapters at seams.** A small interface means a small fixture, and depth means each test exercises a lot of implementation per assertion. Replace an adapter with a fake at a real seam; don't layer mocks over real adapters, and don't mock internals (a sign the interface is wrong or an internal seam is missing). Details in [DEEPENING.md](DEEPENING.md).

## Smells

- **Shallow module**: interface nearly as complex as what it hides. Merge it into a neighbour or pull more behaviour in.
- **Pass-through**: delegates with the same signature. Delete it, or give it a job (a translation, a decision, an invariant).
- **Information leakage**: one decision known in two places. Move it into one module, widening that module's job if needed.
- **Temporal decomposition**: modules split by *when* things happen (read, then parse, then write) instead of by *what each must know*. Regroup around knowledge: a format belongs with both its parser and its writer.
- **Configuration pushed to callers**: parameters callers can't set well because the module knows more than they do. Compute a default inside; keep the parameter only if callers genuinely vary.
- **Mocking internals**: tests reaching past the interface. Reshape the interface or add an internal seam.

## Relationships

- A **module** has exactly one **interface**; its **depth** is measured against that interface.
- A **seam** is where the interface lives; an **enabling point** is where the **adapter** at that seam is chosen.
- Two or more adapters make a seam real.
- **Depth** yields **leverage** for callers and **locality** for maintainers.

## Rejected framings

- **Depth as implementation-lines ÷ interface-lines.** A common reading of Ousterhout's diagram, but as a metric it rewards padding the implementation. Depth here is leverage: behaviour per unit of interface learned.
- **"Interface" as the `interface` keyword or a class's public methods.** Too narrow: interface includes every fact a caller must know.
- **"Unit" as one class tested in isolation with every collaborator mocked.** Tests past the interface and couples tests to implementation. The unit under test is the module, through its interface.
- **"Boundary".** Overloaded with DDD's bounded context. Say seam or interface.
- **An interface for every dependency.** A seam with one adapter adds interface (shallowness) and no leverage.

## Going deeper

- **Deepening a cluster given its dependencies**: [DEEPENING.md](DEEPENING.md): dependency categories, seam discipline, replace-don't-layer testing.
- **Exploring alternative interfaces**: [DESIGN-IT-TWICE.md](DESIGN-IT-TWICE.md): spin up parallel sub-agents to design the interface several radically different ways, then compare on depth, locality, and seam placement.