# AppBase Network — checklist

## New API feature

- [ ] Model `Codable` in `Domain/Model/`
- [ ] `APIEndpoint` case + `urlString` (correct base URL)
- [ ] `*RepositoryProtocol` + live repo calls `APIServiceProtocol` only
- [ ] Decode `BaseResponse<T>` + `unwrap()` at repo (if envelope API)
- [ ] `UseCasePublisher.make` for Combine bridge
- [ ] `*FakeRepository` for DEBUG offline
- [ ] `*ServiceProtocol` + `*ServiceImpl`
- [ ] `Get*UseCase` extends `TrackableUseCase` + protocol with `run` / subjects
- [ ] `RepoFactory` + `ServiceFactory` updated
- [ ] `AppDependencies` exposes use case
- [ ] Coordinator injects into ViewModel
- [ ] ViewModel uses `bindUseCase` with `&cancellables` from `TIOViewModel` (no extra Set in subclass)
- [ ] ViewModel uses `bindUseCase` (not raw `APIService`)

## APIService

- [ ] No `APIService` in ViewController / ViewModel (new code)
- [ ] Completion type explicit: `Result<BaseResponse<Payload>, APIError>` or `Result<Payload, APIError>`
- [ ] POST body type `Encodable`
- [ ] Errors map to `APIError`, not swallowed

## UseCase

- [ ] `execute` returns `AnyPublisher<Output, APIError>`
- [ ] `Input: TrackableUseCaseInput` — `showsLoading`, `showsSuccessToast` (default false), `showsErrorToast`, `successToastMessage`
- [ ] `shouldShowLoading` overridden for load-more / silent calls
- [ ] Protocol for DI (`GetXxxUseCaseProtocol`)

## Pagination

- [ ] `DataPage<T>` when API returns `pages` / `pageSize` / `total` / `list`
- [ ] ViewModel uses `page.canLoadMore` or `hasMorePage()`, not magic `maxPage` unless API requires

## Images from API

- [ ] Logo/avatar URL on model only; display with Kingfisher in cell/view (appbase-ios)

## Testing / DEBUG

- [ ] `AppDependencies.make(useFakeData:)` documented for feature
- [ ] Fake repo returns realistic delay + sample payload
