<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Language;
use App\Models\Translation;
use App\Services\TranslationService;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class TranslationController extends Controller
{
    public function index(Request $request)
    {
        $languageId = $request->query('language_id');
        $scope = $request->query('scope', 'saas');
        $q = $request->query('q');

        $languages = Language::orderBy('name')->get();

        $query = Translation::query()->with('language')->orderBy('key');
        if ($languageId) {
            $query->where('language_id', $languageId);
        }
        if ($scope) {
            $query->where('scope', $scope);
        }
        if ($q) {
            $query->where(function ($sub) use ($q) {
                $sub->where('key', 'like', '%' . $q . '%')
                    ->orWhere('value', 'like', '%' . $q . '%');
            });
        }

        $translations = $query->paginate(25)->withQueryString();

        return view('admin.translations.index', compact('translations', 'languages', 'languageId', 'scope', 'q'));
    }

    public function create()
    {
        $languages = Language::orderBy('name')->get();

        return view('admin.translations.create', compact('languages'));
    }

    public function store(Request $request, TranslationService $service)
    {
        $data = $request->validate([
            'language_id' => ['required', 'exists:languages,id'],
            'scope' => ['required', 'string', 'max:32'],
            'key' => ['required', 'string', 'max:255'],
            'value' => ['required', 'string'],
        ]);

        $translation = Translation::create($data);

        $language = Language::find($translation->language_id);
        if ($language) {
            $service->forget($language->code, $translation->scope);
        }

        return redirect()->route('admin.translations.index')
            ->with('success', 'Translation created.');
    }

    public function edit(Translation $translation)
    {
        $languages = Language::orderBy('name')->get();

        return view('admin.translations.edit', compact('translation', 'languages'));
    }

    public function update(Request $request, Translation $translation, TranslationService $service)
    {
        $data = $request->validate([
            'language_id' => ['required', 'exists:languages,id'],
            'scope' => ['required', 'string', 'max:32'],
            'key' => ['required', 'string', 'max:255', Rule::unique('translations', 'key')
                ->where('scope', $request->input('scope'))
                ->where('language_id', $request->input('language_id'))
                ->ignore($translation->id)],
            'value' => ['required', 'string'],
        ]);

        $translation->update($data);

        $language = Language::find($translation->language_id);
        if ($language) {
            $service->forget($language->code, $translation->scope);
        }

        return redirect()->route('admin.translations.index')
            ->with('success', 'Translation updated.');
    }
}
