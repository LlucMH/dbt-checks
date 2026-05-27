# Pull Request

## Summary

Describe the purpose of this PR.

---

## Type of change

- [ ] Bug fix
- [ ] New check
- [ ] Existing check improvement
- [ ] Documentation update
- [ ] CI / developer experience
- [ ] Refactor
- [ ] Release / metadata update

---

## Checklist

- [ ] I have added or updated integration tests where applicable
- [ ] I have updated documentation where applicable
- [ ] I have updated macro metadata where applicable
- [ ] I have checked NULL-handling behavior where relevant
- [ ] I have checked `where` support where relevant
- [ ] I have checked `group_by` support where relevant
- [ ] I have verified failure outputs are standardized
- [ ] I have run the relevant dbt commands locally or verified CI

---

## dbt validation

Relevant commands run:

```bash
dbt parse
dbt seed
dbt run
dbt test
dbt docs generate