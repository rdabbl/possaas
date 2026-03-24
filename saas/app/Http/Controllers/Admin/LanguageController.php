<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Language;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class LanguageController extends Controller
{
    public function index()
    {
        $languages = Language::orderByDesc('is_default')
            ->orderBy('name')
            ->paginate(20);

        return view('admin.languages.index', compact('languages'));
    }

    public function create()
    {
        return view('admin.languages.create');
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'code' => ['required', 'string', 'max:10', 'unique:languages,code'],
            'name' => ['required', 'string', 'max:255'],
            'native_name' => ['nullable', 'string', 'max:255'],
            'direction' => ['required', Rule::in(['ltr', 'rtl'])],
            'is_active' => ['nullable', 'boolean'],
            'is_default' => ['nullable', 'boolean'],
        ]);

        $data['code'] = strtolower($data['code']);
        $data['is_active'] = $data['is_active'] ?? true;
        $data['is_default'] = $data['is_default'] ?? false;

        if (!empty($data['is_default'])) {
            Language::where('is_default', true)->update(['is_default' => false]);
        }

        Language::create($data);

        return redirect()->route('admin.languages.index')
            ->with('success', 'Language created.');
    }

    public function edit(Language $language)
    {
        return view('admin.languages.edit', compact('language'));
    }

    public function update(Request $request, Language $language)
    {
        $data = $request->validate([
            'code' => ['required', 'string', 'max:10', Rule::unique('languages', 'code')->ignore($language->id)],
            'name' => ['required', 'string', 'max:255'],
            'native_name' => ['nullable', 'string', 'max:255'],
            'direction' => ['required', Rule::in(['ltr', 'rtl'])],
            'is_active' => ['nullable', 'boolean'],
            'is_default' => ['nullable', 'boolean'],
        ]);

        $data['code'] = strtolower($data['code']);
        $data['is_active'] = $data['is_active'] ?? false;
        $data['is_default'] = $data['is_default'] ?? false;

        if (!empty($data['is_default'])) {
            Language::where('is_default', true)
                ->where('id', '!=', $language->id)
                ->update(['is_default' => false]);
        }

        $language->update($data);

        return redirect()->route('admin.languages.index')
            ->with('success', 'Language updated.');
    }
}
